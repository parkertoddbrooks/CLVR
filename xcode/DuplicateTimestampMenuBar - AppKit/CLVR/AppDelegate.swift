import Cocoa
import UserNotifications

// date format 
enum NamingFormat: String, CaseIterable {
    case setting01 = "Setting01"
    case setting02 = "Setting02"
    
    var displayName: String {
        switch self {
        case .setting01:
            return "name--yyyy-MM-dd--HH-mm-ss.filename-extension (default)"
        case .setting02:
            return "name-copy--yyyy-MM-dd--HH-mm-ss.filename-extension"
        }
    }
    
    var usesCopy: Bool {
        switch self {
        case .setting01:
            return false
        case .setting02:
            return true
        }
    }
}

/// Defines different log levels for the application.
///
/// Each case represents a severity level for logging with a corresponding string value.
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

/// Logs a message with timestamp, log level, and source information to a file.
///
/// - Parameters:
///   - message: The message to be logged.
///   - level: The severity level of the log message. Defaults to .info.
///   - fileName: The name of the file where the log was called. Defaults to the current file.
///   - lineNumber: The line number where the log was called. Defaults to the current line.
///   - functionName: The name of the function where the log was called. Defaults to the current function.
/// - Throws: An error if there's a problem writing to the log file.
func log(_ message: String, level: LogLevel = .info, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = dateFormatter.string(from: Date())
    
    let fileURL = URL(fileURLWithPath: fileName)
    let fileNameOnly = fileURL.lastPathComponent
    
    let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileNameOnly):\(lineNumber) \(functionName)] \(message)"
    
    print("Attempting to log: \(logMessage)")
    
    // Write to file
    let fileManager = FileManager.default
    let logDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        .appendingPathComponent("DuplicateTimestampMenuBar")
        .appendingPathComponent("Logs")
    let logFile = logDirectory.appendingPathComponent("DuplicateWithTimestamp-swift.log")

    print("Log directory: \(logDirectory.path)")
    print("Log file: \(logFile.path)")

    do {
        try fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true, attributes: nil)
        print("Log directory created or already exists")
        
        if fileManager.fileExists(atPath: logFile.path) {
            print("Log file exists, appending")
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                fileHandle.write((logMessage + "\n").data(using: .utf8)!)
                print("Log message appended successfully")
            } else {
                print("Failed to get file handle for appending")
            }
        } else {
            print("Log file doesn't exist, creating new file")
            try (logMessage + "\n").write(to: logFile, atomically: true, encoding: .utf8)
            print("New log file created with message")
        }
    } catch {
        print("Error writing to log file: \(error.localizedDescription)")
        print("Error details: \(error)")
    }
}
    
/// A class that watches for file system events in specified paths.
///
/// This class uses the FSEvents API to monitor changes in the file system and call a provided callback when changes occur.
///
/// - Note: This class automatically starts watching upon initialization and stops when deinitialized.
class FileSystemWatcher {
    private var stream: FSEventStreamRef?
    private let callback: (String) -> Void
    private let queue: DispatchQueue

    /// Initializes a new FileSystemWatcher instance.
    ///
    /// - Parameters:
    ///   - paths: An array of file system paths to watch for changes.
    ///   - callback: A closure that will be called with the path of any changed file or directory.
    init(paths: [String], callback: @escaping (String) -> Void) {
        self.callback = callback
        self.queue = DispatchQueue(label: "com.yourapp.fseventstream", qos: .utility)
        
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        
        stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            { (_, info, numEvents, eventPaths, _, _) in
                guard let info = info else { return }
                let watcher = Unmanaged<FileSystemWatcher>.fromOpaque(info).takeUnretainedValue()
                let paths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]
                for i in 0..<numEvents {
                    watcher.callback(paths[Int(i)])
                }
            },
            &context,
            paths as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0,
            flags
        )
        
        if let stream = stream {
            FSEventStreamSetDispatchQueue(stream, queue)
            FSEventStreamStart(stream)
        }
    }

    /// Stops watching and releases resources when the instance is deinitialized.
    deinit {
        if let stream = stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
    }
}

/// The main application delegate class responsible for managing the app's lifecycle and core functionality.
///
/// This class handles the setup of the status bar item, menu, file system watching,
/// and manages the app's enabled/disabled state.
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    /// Shared instance of the AppDelegate for global access.
    static var shared: AppDelegate!
    
    /// The status item displayed in the macOS menu bar.
    var statusItem: NSStatusItem?
    
    /// Indicates whether the app's main functionality is enabled.
    /// When changed, it updates the status item icon and saves the state to UserDefaults.
    var isEnabled: Bool = true {
        didSet {
            updateStatusItemIcon()
            updateToggleSwitch()
            if isEnabled {
                startWatching()
            } else {
                stopWatching()
            }
        }
    }
    
    /// The file system watcher responsible for detecting file changes.
    private var fileSystemWatcher: FileSystemWatcher?
    
    /// Indicates whether the app is in debug mode.
    var isDebugMode = false
    
    /// The debug window for displaying additional information when in debug mode.
    var debugWindow: NSWindow?
    
    /// Security-scoped bookmark for the Desktop folder.
    private var desktopBookmark: Data?
    
    /// Security-scoped bookmark for the Documents folder.
    private var documentsBookmark: Data?
    
    /// Dictionary to store previous file information.
    private var previousFiles: [String: [String]] = [:]
    
    /// Set of recently processed files to prevent duplicate processing.
    private var recentlyProcessedFiles: Set<String> = []
    
    /// The ToggleView instance for the menu item.
    private var toggleView: ToggleView?
    
    /// The log window for displaying the log file contents.
    var logWindow: NSWindow?
    
    /// Indicates whether the log window is currently visible.
    var isLogWindowVisible = false
    
    /// The about window for displaying app information.
    var aboutWindow: NSWindow?

    private var aboutWindowController: NSWindowController?
    
    private let selectedNamingFormatKey = "selectedNamingFormat"
    
    // date format 
    var savedNamingFormat: NamingFormat {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: selectedNamingFormatKey),
               let format = NamingFormat(rawValue: rawValue) {
                return format
            }
            return .setting01 // Default value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedNamingFormatKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // Ensure consistent use of savedNamingFormat
    func applyNamingFormat(to fileName: String) -> String {
        let format = savedNamingFormat
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd--HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        
        switch format {
        case .setting01:
            return "\(fileNameWithoutExtension)--\(timestamp).\(fileExtension)"
        case .setting02:
            return "\(fileNameWithoutExtension)-copy--\(timestamp).\(fileExtension)"
        }
    }
    
    /// Displays the "About" window for the application.
    ///
    /// This function creates and shows a new "About" window, making it the key window
    /// and bringing the application to the foreground. It performs these operations
    /// asynchronously on the main dispatch queue to ensure thread safety and proper UI updates.
    ///
    /// - Note: This function uses weak self to prevent potential retain cycles in the closure.
    ///
    /// - Important: If the AppDelegate instance is deallocated before or during the execution
    ///   of this function, the operation will be safely aborted.
    ///
    /// - SeeAlso: `createAboutWindow()` method, which is responsible for creating the actual window content.
    @objc func showAboutWindow() {
        log("showAboutWindow called", level: .debug)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                log("Self is nil in showAboutWindow", level: .error)
                return
            }
            if self.aboutWindowController == nil {
                log("Creating new about window", level: .debug)
                let window = self.createAboutWindow()
                window.delegate = self  // Set the window's delegate
                self.aboutWindowController = NSWindowController(window: window)
            } else {
                log("About window already exists", level: .debug)
            }

            log("Showing about window", level: .debug)
            self.aboutWindowController?.showWindow(nil)

            if let window = self.aboutWindowController?.window {
                log("Making about window key window", level: .debug)
                window.makeKeyAndOrderFront(nil)
            }

            log("Activating app", level: .debug)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // NSWindowDelegate method
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window == aboutWindowController?.window {
            aboutWindowController = nil
            log("About window closed, controller set to nil", level: .debug)
        }
    }

    /// Initializes the AppDelegate.
    override init() {
        super.init()
        log("AppDelegate initialized")
        log("AppDelegate initialized")
    }

    /// Called when the application finishes launching.
    ///
    /// - Parameter notification: The notification object.
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        print("Application did finish launching")
        
        testLogging()
        
        // Always start in the "on" state
        isEnabled = true
        
        setupStatusItem()
        setupMenu()
        
        log("Initial state: enabled")
        
        // Start watching since we're always starting in the "on" state
        startWatching()
        
        if let savedBookmark = UserDefaults.standard.data(forKey: "DocumentsBookmark") {
            documentsBookmark = savedBookmark
        }
        
        if !verifyFolderAccess() {
            log("No access to watched folders, requesting permission")
            requestPermission()
        }
        
        testLogWriting()
        
        log("Application launched successfully", level: .info)
        
        // Set initial dock visibility
        updateDockVisibility()
        
        setupMainMenu()

        // Set default values for showInDock and showInMenuBar if not already set
        if UserDefaults.standard.object(forKey: "ShowInDock") == nil {
            showInDock = true
        }
        if UserDefaults.standard.object(forKey: "ShowInMenuBar") == nil {
            showInMenuBar = true
        } else {
            // If showInMenuBar was previously set, make sure to update visibility
            updateMenuBarVisibility()
        }

        updateDockVisibility()

        // Set default value for selectedNamingFormat if not already set
        if UserDefaults.standard.string(forKey: "selectedNamingFormat") == nil {
            UserDefaults.standard.set(NamingFormat.setting01.rawValue, forKey: "selectedNamingFormat")
            UserDefaults.standard.synchronize()
        }

        let savedFormat = savedNamingFormat
        log("Loaded naming format on app launch: \(savedFormat.rawValue)", level: .debug)
        log("Loaded naming format on app launch: \(savedNamingFormat.rawValue)", level: .debug)

    }

    /// Sets up the status item in the menu bar.
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.action = #selector(toggleMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.wantsLayer = true
        }
        updateStatusItemIcon()
        log("Status item set up")
    }

    /// Sets up the menu for the status item.
    func setupMenu() {
        let menu = NSMenu()
        menu.delegate = self

        let customMenuItem = NSMenuItem()
        toggleView = ToggleView(title: "CLVR", isOn: isEnabled, target: self, action: #selector(toggleFeature))
        customMenuItem.view = toggleView
        menu.addItem(customMenuItem)

        menu.addItem(NSMenuItem.separator())

        let aboutMenuItem = NSMenuItem(title: "About CLVR", action: #selector(showAboutWindow), keyEquivalent: "")
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)

        menu.addItem(NSMenuItem.separator())

        let settingsMenuItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: "")
        settingsMenuItem.target = self
        menu.addItem(settingsMenuItem)

        let logMenuItem = NSMenuItem(title: "Open Log File...", action: #selector(openLogFile), keyEquivalent: "")
        logMenuItem.target = self
        menu.addItem(logMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        menu.addItem(quitItem)

        statusItem?.menu = menu
        log("Menu set up")
    }

    /// Called when the application is about to terminate.
    ///
    /// - Parameter notification: The notification object.
    func applicationWillTerminate(_ notification: Notification) {
        log("Application will terminate")
        stopWatching()
        stopAccessingSecurityScopedResources()
    }

    /// Toggles the menu when the status item is clicked.
    @objc func toggleMenu() {
        log("Menu toggled")
        statusItem?.button?.performClick(nil)
    }

    /// Toggles the main feature on and off.
    ///
    /// - Parameter sender: The NSSwitch that triggered the action.
    @objc func toggleFeature(_ sender: NSSwitch) {
        log("Toggle feature called")
        isEnabled = sender.state == .on
        log("Feature toggled: \(isEnabled ? "enabled" : "disabled")")
        
        // Simply update the icon without animation
        updateStatusItemIcon()
    }

    /// Starts watching for file system events.
    func startWatching() {
        log("Starting file watching")
        let watchedPaths = getWatchedPaths()
        log("Watched paths: \(watchedPaths)")
        fileSystemWatcher = FileSystemWatcher(paths: watchedPaths) { [weak self] path in
            self?.handleFileSystemEvent(path: path)
        }
        log("FileSystemWatcher initialized")
    }

    /// Stops watching for file system events.
    func stopWatching() {
        log("Stopping file watching")
        fileSystemWatcher = nil
    }

    /// Retrieves the paths to be watched for file system events.
    ///
    /// - Returns: An array of string paths to be watched.
    func getWatchedPaths() -> [String] {
        var paths: [String] = []
        
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            paths.append(desktopURL.path)
            log("Desktop path: \(desktopURL.path)")
        }
        
        if let documentsURL = resolveDocumentsBookmark() {
            paths.append(documentsURL.path)
            log("Documents path: \(documentsURL.path)")
        }
        
        log("Watched paths: \(paths)")
        return paths
    }

    /// Requests permission to access the Desktop and Documents folders.
    func requestPermission() {
        log("Requesting permission for Desktop and Documents folders")
        
        let desktopAccess = requestFolderAccess(for: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop"), name: "Desktop")
        let documentsAccess = requestFolderAccess(for: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents"), name: "Documents")
        
        if desktopAccess && documentsAccess {
            if verifyFolderAccess() {
                log("Folder access verified, starting file watching")
                startWatching()
            } else {
                log("Folder access verification failed", level: .error)
                showAccessDeniedAlert()
            }
        } else {
            log("User didn't select both folders. Desktop: \(desktopAccess), Documents: \(documentsAccess)", level: .warning)
            showAccessDeniedAlert()
        }
    }

    /// Requests access to a specific folder.
    ///
    /// - Parameters:
    ///   - url: The URL of the folder to request access for.
    ///   - name: The name of the folder (e.g., "Desktop" or "Documents").
    /// - Returns: A boolean indicating whether access was granted.
    private func requestFolderAccess(for url: URL, name: String) -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Please select your \(name) folder"
        openPanel.directoryURL = url
        openPanel.prompt = "Select \(name)"
        
        if openPanel.runModal() == .OK, let selectedURL = openPanel.url {
            if name == "Documents" {
                do {
                    let bookmark = try selectedURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    documentsBookmark = bookmark
                    UserDefaults.standard.set(bookmark, forKey: "DocumentsBookmark")
                    log("Documents folder selected and bookmark created: \(selectedURL.path)")
                } catch {
                    log("Error creating bookmark for Documents: \(error.localizedDescription)", level: .error)
                    return false
                }
            }
            log("\(name) folder selected: \(selectedURL.path)")
            return true
        } else {
            log("No \(name) folder selected")
            return false
        }
    }

    private func stopAccessingSecurityScopedResources() {
        if let documentsURL = resolveDocumentsBookmark() {
            documentsURL.stopAccessingSecurityScopedResource()
        }
    }

    // start rename

    /// Dictionary to store information about items being monitored for stability
    private var monitoredItems: [String: (size: Int64, date: Date, contentHash: Int, checkCount: Int)] = [:]

    /// Handles file system events, initiating the monitoring process for items that need to be renamed
    func handleFileSystemEvent(path: String) {
        log("File system event detected: \(path)")
        
        if recentlyProcessedFiles.contains(path) {
            log("Item was recently processed, skipping: \(path)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let name = url.lastPathComponent
        
        log("Checking if item should be renamed: \(name)")
        if shouldRenameFile(at: url) {
            log("Item should be renamed, starting monitoring: \(name)")
            startMonitoringItem(at: path)
        } else {
            log("Item does not need to be renamed: \(name)")
        }
    }

    /// Starts monitoring an item (file or folder) for stability
    func startMonitoringItem(at path: String) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            let size = attributes[.size] as? Int64 ?? 0
            let modificationDate = attributes[.modificationDate] as? Date ?? Date()
            let isDirectory = attributes[.type] as? FileAttributeType == .typeDirectory
            
            let contentHash = isDirectory ? calculateFolderContentHash(path: path) : 0
            
            monitoredItems[path] = (size: size, date: modificationDate, contentHash: contentHash, checkCount: 0)
            checkItemStability(path: path)
        } catch {
            log("Failed to get item attributes for: \(path)", level: .error)
        }
    }

    /// Checks the stability of a monitored item
    func checkItemStability(path: String) {
        guard var itemInfo = monitoredItems[path] else { return }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            let newSize = attributes[.size] as? Int64 ?? 0
            let newModificationDate = attributes[.modificationDate] as? Date ?? Date()
            let isDirectory = attributes[.type] as? FileAttributeType == .typeDirectory
            
            let newContentHash = isDirectory ? calculateFolderContentHash(path: path) : 0

            if newSize == itemInfo.size && newModificationDate == itemInfo.date && newContentHash == itemInfo.contentHash {
                itemInfo.checkCount += 1
                if itemInfo.checkCount >= 3 {  // Item has been stable for 3 checks
                    monitoredItems.removeValue(forKey: path)
                    renameFile(at: path)
                    return
                }
            } else {
                itemInfo.size = newSize
                itemInfo.date = newModificationDate
                itemInfo.contentHash = newContentHash
                itemInfo.checkCount = 0
            }

            monitoredItems[path] = itemInfo

            // Check again after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkItemStability(path: path)
            }
        } catch {
            log("Error checking item stability: \(error.localizedDescription)", level: .error)
            monitoredItems.removeValue(forKey: path)
        }
    }

    /// Calculates a hash value representing the contents of a folder
    func calculateFolderContentHash(path: String) -> Int {
        var hasher = Hasher()
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            for item in contents {
                hasher.combine(item)
                let itemPath = (path as NSString).appendingPathComponent(item)
                if let attributes = try? FileManager.default.attributesOfItem(atPath: itemPath) {
                    hasher.combine(attributes[.size] as? Int64 ?? 0)
                    hasher.combine(attributes[.modificationDate] as? Date ?? Date())
                }
            }
        } catch {
            log("Error calculating folder content hash: \(error.localizedDescription)", level: .error)
        }
        return hasher.finalize()
    }

    /// Determines if a file should be renamed based on its filename and date added.
    ///
    /// - Parameter url: The URL of the file to check.
    /// - Returns: A boolean indicating whether the file should be renamed.
    func shouldRenameFile(at url: URL) -> Bool {
        let filename = url.lastPathComponent
        let name = (filename as NSString).deletingPathExtension.lowercased()
        let hasCopySuffix = name.hasSuffix(" copy") || name.matches(regex: #" copy \d+$"#)
        
        guard hasCopySuffix else { return false }
        
        // Check if the file was just added
        if let dateAdded = try? url.resourceValues(forKeys: [.addedToDirectoryDateKey]).addedToDirectoryDate,
           Date().timeIntervalSince(dateAdded) < 5 { // Consider files added within the last 5 seconds
            log("File was just added: \(filename)")
            return true
        }
        
        log("File was not just added: \(filename)")
        return false
    }

    /// Renames a file by adding a timestamp to its name.
    ///
    /// - Parameter path: The path of the file to rename.
    func renameFile(at path: String) {
        log("Attempting to rename item: \(path)")
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()
        let fileExtension = url.pathExtension
        var name = url.lastPathComponent

        // If the file has an extension, remove it from the name
        if !fileExtension.isEmpty {
            name = (name as NSString).deletingPathExtension
        }

        log("Item details - Name: \(name), Extension: \(fileExtension)")

        let timestamp = formattedTimestamp()
        var newName: String

        // Remove " copy" or " copy X" suffix
        if name.lowercased().hasSuffix(" copy") {
            name = (name as NSString).substring(to: name.count - 5)
        } else if let range = name.range(of: #" copy \d+$"#, options: .regularExpression) {
            name = String(name[..<range.lowerBound])
        }

        let selectedFormat = savedNamingFormat
        log("Using naming format: \(selectedFormat.rawValue)", level: .debug)

        if selectedFormat.usesCopy {
            newName = "\(name)-copy--\(timestamp)"
        } else {
            newName = "\(name)--\(timestamp)"
        }

        // Add the file extension back only if it originally had one
        if !fileExtension.isEmpty {
            newName += ".\(fileExtension)"
        }

        log("New name: \(newName)", level: .debug)

        var newPath = directory.appendingPathComponent(newName).path

        // Check if the new filename already exists
        var counter = 1
        while FileManager.default.fileExists(atPath: newPath) {
            var counterName: String
            if selectedFormat.usesCopy {
                counterName = "\(name)-copy--\(timestamp) (\(counter))"
            } else {
                counterName = "\(name)--\(timestamp) (\(counter))"
            }
            
            // Add the file extension back only if it originally had one
            if !fileExtension.isEmpty {
                counterName += ".\(fileExtension)"
            }
            
            newPath = directory.appendingPathComponent(counterName).path
            counter += 1
        } 

        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
            log("Successfully renamed: \(path) to \(newPath)")
            
            // Add the new path to recently processed files
            recentlyProcessedFiles.insert(newPath)
            
            // Remove the new path from recently processed files after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.recentlyProcessedFiles.remove(newPath)
            }
            
            // Trigger the animation after successful renaming
            DispatchQueue.main.async { [weak self] in
                self?.animateStatusItemIcon()
            }
        } catch {
            log("Error renaming item: \(error.localizedDescription)", level: .error)
        }
    }

    /// Generates a formatted timestamp string for use in file naming.
    ///
    /// This function creates a timestamp string in the format "yyyy-MM-dd-HHmmss" 
    /// representing the current date and time. It's primarily used for appending 
    /// to filenames when creating copies or renaming files.
    ///
    /// - Returns: A `String` containing the formatted timestamp.
    ///
    /// - Note: The timestamp format is fixed and does not account for localization 
    ///         or time zones. It uses the system's current date and time.
    private func formattedTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd--HH-mm-ss"
        return dateFormatter.string(from: Date())
    }
    // stop rename  
   
    /// Updates the status item icon in the menu bar based on the current enabled state of the application.
    ///
    /// This function sets the appropriate icon for the status item depending on whether the application
    /// is enabled or disabled. It uses SF Symbols for the icons and applies a custom configuration.
    ///
    /// - Note: The function uses "command.square.fill" for the enabled state and "command.square" for the disabled state.
    ///
    /// - Important: If the system symbol fails to load, an error message is logged.
    ///
    /// - SeeAlso: `isEnabled` property, which determines which icon to display.
    func updateStatusItemIcon() {
        let iconName = isEnabled ? "command.square.fill" : "command.square"
        
        let configuration = NSImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?.withSymbolConfiguration(configuration) {
            image.isTemplate = true
            statusItem?.button?.image = image
            
            // Reduce padding by setting a custom length
            statusItem?.length = NSStatusItem.squareLength
        } else {
            log("Failed to load system symbol: \(iconName)", level: .error)
        }
    }

    func animateStatusItemIcon() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let button = self.statusItem?.button,
                  let originalImage = button.image else {
                return
            }
            
            // Create the animated image with the larger size
            let configuration = NSImage.SymbolConfiguration(pointSize: 17, weight: .regular)
            guard let animatedImage = NSImage(systemSymbolName: "d.circle.fill", accessibilityDescription: nil)?.withSymbolConfiguration(configuration) else {
                log("Failed to load system symbol: d.circle.fill", level: .warning)
                return
            }
            
            // Perform the animation
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                button.animator().alphaValue = 0.5
                button.image = animatedImage
            }, completionHandler: {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    context.allowsImplicitAnimation = true
                    button.animator().alphaValue = 1.0
                }, completionHandler: {
                    // Always reset to the original icon after animation
                    button.image = originalImage
                })
            })
        }
    }

    @objc dynamic var showInDock: Bool {
        get {
            UserDefaults.standard.bool(forKey: "ShowInDock")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ShowInDock")
            updateDockVisibility()
        }
    }

    @objc dynamic var showInMenuBar: Bool {
        get {
            UserDefaults.standard.bool(forKey: "ShowInMenuBar")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ShowInMenuBar")
            updateMenuBarVisibility()
        }
    }

    func updateDockVisibility() {
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    func updateMenuBarVisibility() {
        statusItem?.isVisible = showInMenuBar
    }

    /// Sends a local notification to the user with the specified title and message.
    ///
    /// This function creates and schedules a local notification using the UserNotifications framework.
    /// The notification is displayed immediately as no trigger is specified.
    ///
    /// - Parameters:
    ///   - title: A String representing the title of the notification.
    ///   - message: A String representing the body message of the notification.
    ///
    /// - Note: This function requires the app to have permission to send notifications.
    ///         Ensure that notification permissions are requested and granted before calling this function.
    ///
    /// - Important: If an error occurs while adding the notification request, it will be logged
    ///              using the app's logging system with an error level.
    func sendNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                log("Error sending notification: \(error.localizedDescription)", level: .error)
            }
        }
    }

    private func resolveDocumentsBookmark() -> URL? {
        guard let bookmark = documentsBookmark else {
            log("No bookmark found for Documents", level: .warning)
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                log("Bookmark for Documents is stale", level: .warning)
                // Here you might want to request new permission and create a new bookmark
                return nil
            }
            
            if url.startAccessingSecurityScopedResource() {
                return url
            } else {
                log("Failed to access security-scoped resource for Documents", level: .error)
                return nil
            }
        } catch {
            log("Error resolving bookmark for Documents: \(error.localizedDescription)", level: .error)
            return nil
        }
    }

    func verifyFolderAccess() -> Bool {
        let paths = getWatchedPaths()
        log("Verifying folder access for paths: \(paths)")
        let result = !paths.isEmpty && paths.allSatisfy { path in
            let isReadable = FileManager.default.isReadableFile(atPath: path)
            let isWritable = FileManager.default.isWritableFile(atPath: path)
            log("Path: \(path), Readable: \(isReadable), Writable: \(isWritable)")
            return isReadable && isWritable
        }
        log("Folder access verification result: \(result)")
        return result
    }

    func showAccessDeniedAlert() {
        log("Failed to gain access to watched folders", level: .error)
        let failureAlert = NSAlert()
        failureAlert.messageText = "Folder Access Required"
        failureAlert.informativeText = "CLVR needs access to your Desktop and Documents folders to function properly. Please select these folders when prompted by the app."
        failureAlert.alertStyle = .warning
        failureAlert.addButton(withTitle: "Request Access")
        failureAlert.addButton(withTitle: "Cancel and Quit")
        
        let response = failureAlert.runModal()
        if response == .alertFirstButtonReturn {
            requestPermission()
        } else {
            // User chose "Cancel and Quit"
            NSApplication.shared.terminate(nil)
        }
    }

    func testFileCreation() {
        let testFile = (NSHomeDirectory() as NSString).appendingPathComponent("Desktop/TestFile.txt")
        FileManager.default.createFile(atPath: testFile, contents: nil, attributes: nil)
        log("Test file created: \(testFile)")
    }

    func testLogWriting() {
        log("Test log message", level: .debug)
        
        let fileManager = FileManager.default
        let logDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("DuplicateTimestampMenuBar")
            .appendingPathComponent("Logs")
        let logFile = logDirectory.appendingPathComponent("DuplicateWithTimestamp-swift.log")
        
        if fileManager.fileExists(atPath: logFile.path) {
            do {
                let contents = try String(contentsOf: logFile, encoding: .utf8)
                print("Log file contents:\n\(contents)")
            } catch {
                print("Error reading log file: \(error)")
            }
        } else {
            print("Log file does not exist at path: \(logFile.path)")
        }
    }

    func testLogging() {
        print("Starting logging test")
        
        log("Test log message 1", level: .debug)
        log("Test log message 2", level: .info)
        log("Test log message 3", level: .warning)
        
        let fileManager = FileManager.default
        let logDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("DuplicateTimestampMenuBar")
            .appendingPathComponent("Logs")
        let logFile = logDirectory.appendingPathComponent("DuplicateWithTimestamp-swift.log")
        
        print("Checking for log file at: \(logFile.path)")
        
        if fileManager.fileExists(atPath: logFile.path) {
            print("Log file exists")
            do {
                let contents = try String(contentsOf: logFile, encoding: .utf8)
                print("Log file contents:\n\(contents)")
            } catch {
                print("Error reading log file: \(error)")
            }
        } else {
            print("Log file does not exist")
        }
        
        print("Logging test completed")
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        updateToggleSwitch()
    }

    func menuDidClose(_ menu: NSMenu) {
        // No need to update here
    }

    // MARK: - ToggleView updates

    func updateToggleSwitch() {
        toggleView?.isOn = isEnabled
    }

    func setupMainMenu() {
        let mainMenu = NSMenu()
        
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = NSMenu(title: "CLVR")
        
        let aboutMenuItem = NSMenuItem(title: "About CLVR", action: #selector(showAboutWindow), keyEquivalent: "")
        aboutMenuItem.target = self
        appMenuItem.submenu?.addItem(aboutMenuItem)
        
        appMenuItem.submenu?.addItem(NSMenuItem.separator())
        
        let settingsMenuItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ",")
        settingsMenuItem.target = self
        appMenuItem.submenu?.addItem(settingsMenuItem)

        let logMenuItem = NSMenuItem(title: "Open Log File...", action: #selector(openLogFile), keyEquivalent: "l")
        logMenuItem.target = self
        appMenuItem.submenu?.addItem(logMenuItem)
        
        appMenuItem.submenu?.addItem(NSMenuItem.separator())
        
        let quitMenuItem = NSMenuItem(title: "Quit CLVR", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitMenuItem.target = NSApp
        appMenuItem.submenu?.addItem(quitMenuItem)
        
        mainMenu.addItem(appMenuItem)
        
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        let editMenuItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        
        NSApp.mainMenu = mainMenu
    }

    // New functions for log window functionality
    @objc func openLogFile() {
        let fileManager = FileManager.default
        guard let containerURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            log("Unable to access application support directory", level: .error)
            return
        }

        let logFile = containerURL
            .appendingPathComponent("DuplicateTimestampMenuBar")
            .appendingPathComponent("Logs")
            .appendingPathComponent("DuplicateWithTimestamp-swift.log")

        if fileManager.fileExists(atPath: logFile.path) {
            NSWorkspace.shared.open(logFile)
        } else {
            log("Log file not found at path: \(logFile.path)", level: .error)
            // Optionally, show an alert to the user
            let alert = NSAlert()
            alert.messageText = "Log File Not Found"
            alert.informativeText = "The log file could not be found at the expected location."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }


    /// Creates and configures the about window for the application.
    ///
    /// This function sets up a new NSWindow instance with predefined dimensions and style,
    /// populating it with information about the application including its icon, name,
    /// version, and copyright details.
    ///
    /// - Returns: An NSWindow instance configured as the about window.
    ///
    /// - Note: The window is set up with a size of 300x200 pixels and includes the app icon,
    ///         app name, version number, and copyright information.
    ///
    /// - Important: This method assumes that an "AppIcon" image is available in the asset catalog.
    ///              If the icon is not found, a warning will be logged.
    ///
    /// - SeeAlso: `NSWindow`, `NSImageView`, `NSTextField`

    func createAboutWindow() -> NSWindow {
        log("createAboutWindow called", level: .debug)
        let window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
                              styleMask: [.titled, .closable, .miniaturizable],
                              backing: .buffered,
                              defer: false)
        window.title = "About CLVR"
        window.center()

        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        window.contentView = contentView

        // App Icon
        let iconSize: CGFloat = 60
        let iconView = NSImageView(frame: NSRect(x: (300 - iconSize) / 2, y: 120, width: iconSize, height: iconSize))
        if let appIcon = NSImage(named: "AppIcon") {
            iconView.image = appIcon
            log("AppIcon loaded successfully", level: .debug)
        } else {
            log("AppIcon not found in asset catalog", level: .warning)
        }
        contentView.addSubview(iconView)

        // App Name
        let nameLabel = NSTextField(labelWithString: "CLVR")
        nameLabel.font = NSFont.boldSystemFont(ofSize: 16)
        nameLabel.alignment = .center
        nameLabel.frame = NSRect(x: 0, y: 90, width: 300, height: 20)
        contentView.addSubview(nameLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "Version 1.00")
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.alignment = .center
        versionLabel.frame = NSRect(x: 0, y: 70, width: 300, height: 20)
        contentView.addSubview(versionLabel)

        // Copyright
        let copyrightLabel = NSTextField(labelWithString: "Copyright © 2024 Parker Todd Brooks\nAll rights reserved.")
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.alignment = .center
        copyrightLabel.frame = NSRect(x: 0, y: 20, width: 300, height: 40)
        contentView.addSubview(copyrightLabel)

        // Set up the window to close with Command+W
        window.standardWindowButton(.closeButton)?.keyEquivalent = "w"
        window.standardWindowButton(.closeButton)?.keyEquivalentModifierMask = .command

        log("About window created successfully", level: .debug)
        return window
    }

    private var settingsWindow: NSWindow?
    private var settingsWindowController: NSWindowController?

    // DATE PREF
    @objc func showSettingsWindow() {
        if settingsWindow == nil {
            settingsWindow = createSettingsWindow()
            settingsWindowController = NSWindowController(window: settingsWindow)
        }
        
        // Update the existing window to reflect current preferences
        if let dateFormatPopup = settingsWindow?.contentView?.subviews.compactMap({ $0 as? NSPopUpButton }).first {
            let savedFormat = savedNamingFormat
            log("Current saved format when showing settings: \(savedFormat.rawValue)", level: .debug)
            
            if let index = NamingFormat.allCases.firstIndex(of: savedFormat) {
                dateFormatPopup.selectItem(at: index)
                log("Selected item in popup after setting: \(dateFormatPopup.titleOfSelectedItem ?? "None")", level: .debug)
            } else {
                log("Saved format not found in popup items. Available items: \(dateFormatPopup.itemTitles)", level: .warning)
            }
        }
        
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    /// Settings Window
    ///
    /// Creates and configures the settings window for the application.
    ///
    /// This method sets up a window with various UI elements for configuring application settings,
    /// including options for showing the app in the Dock and Menu Bar, and selecting a date format.
    ///
    /// - Returns: A configured NSWindow instance representing the settings window.
    ///
    /// - Note: This method creates labels, toggle switches, and a popup button for various settings.
    ///         The window's appearance is customized with specific colors and layout.
    func createSettingsWindow() -> NSWindow {
        // Increase the window height to accommodate the additional padding
        let window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 600, height: 205),
                              styleMask: [.titled, .closable, .miniaturizable],
                              backing: .buffered,
                              defer: false)
        window.title = "Settings"
        window.center()

        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        window.contentView = contentView

        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(named: "ContainerMainBackground")?.cgColor

        // Create a custom NSView subclass
        class MainContainerView: NSView {
            override init(frame frameRect: NSRect) {
                super.init(frame: frameRect)

                // Enable layer-backed view
                self.wantsLayer = true

                // Configure the layer properties
                self.layer?.cornerRadius = 10
                self.layer?.borderWidth = 1
            }

            required init?(coder decoder: NSCoder) {
                super.init(coder: decoder)
            }

            // Override wantsUpdateLayer to return true
            override var wantsUpdateLayer: Bool {
                return true
            }

            // Override updateLayer to update the layer's properties
            override func updateLayer() {
                super.updateLayer()

                // Update the background color
                self.layer?.backgroundColor = NSColor(named: "ContainerInnerBackground")?.cgColor

                // Update the border color
                self.layer?.borderColor = NSColor(named: "ContainerBorder")?.cgColor
            }
        }

        // Use the custom MainContainerView
        let mainContainer = MainContainerView(frame: NSRect(x: 20, y: 20, width: 560, height: 165))
        contentView.addSubview(mainContainer)

        // Adjust the starting y-offset
        var yOffset = 130

        // Show in Dock
        let dockLabel = createLabel(text: "Show in dock", fontSize: 13, bold: false)
        dockLabel.frame = NSRect(x: 20, y: yOffset, width: 400, height: 20)
        mainContainer.addSubview(dockLabel)

        let dockToggle = createToggleSwitch(frame: NSRect(x: 500, y: yOffset, width: 40, height: 20))
        dockToggle.state = showInDock ? .on : .off  // Set initial state
        dockToggle.bind(.value, to: self, withKeyPath: "showInDock", options: nil)
        mainContainer.addSubview(dockToggle)

        yOffset -= 20
        let dockDescription = createLabel(text: "App will appear in Dock, Switcher, and 'Force Quit Applications'", fontSize: 11, color: .secondaryLabelColor)
        dockDescription.frame = NSRect(x: 20, y: yOffset, width: 520, height: 20)
        mainContainer.addSubview(dockDescription)

        yOffset -= 10
        let separator1 = NSBox(frame: NSRect(x: 20, y: yOffset, width: 520, height: 1))
        separator1.boxType = .separator
        mainContainer.addSubview(separator1)

        yOffset -= 30
        // Show in Menu Bar 
        let menuBarLabel = createLabel(text: "Show in menu bar", fontSize: 13, bold: false)
        menuBarLabel.frame = NSRect(x: 20, y: yOffset, width: 400, height: 20)
        mainContainer.addSubview(menuBarLabel)

        let menuBarToggle = createToggleSwitch(frame: NSRect(x: 500, y: yOffset, width: 40, height: 20))
        menuBarToggle.state = showInMenuBar ? .on : .off  // Set initial state
        menuBarToggle.bind(.value, to: self, withKeyPath: "showInMenuBar", options: nil)
        mainContainer.addSubview(menuBarToggle)

        yOffset -= 20
        let menuBarDescription = createLabel(text: "If off, 'Show in dock' must be on", fontSize: 11, color: .secondaryLabelColor)
        menuBarDescription.frame = NSRect(x: 20, y: yOffset, width: 520, height: 20)
        mainContainer.addSubview(menuBarDescription)

        yOffset -= 10
        let separator2 = NSBox(frame: NSRect(x: 20, y: yOffset, width: 520, height: 1))
        separator2.boxType = .separator
        mainContainer.addSubview(separator2)

        yOffset -= 30
        // Date Format
        // (⌘D)
        let dateFormatLabel = createLabel(text: "File rename formatting", fontSize: 13, bold: false)
        dateFormatLabel.frame = NSRect(x: 20, y: yOffset, width: 200, height: 20)
        mainContainer.addSubview(dateFormatLabel)

        let dateFormatPopup = createPopUpButton(frame: NSRect(x: 270, y: yOffset, width: 270, height: 24))
        let formats = NamingFormat.allCases.map { $0.displayName }
        dateFormatPopup.addItems(withTitles: formats)
        
        let savedFormat = savedNamingFormat
        log("Saved format when creating settings window: \(savedFormat.rawValue)", level: .debug)
        
        if let index = NamingFormat.allCases.firstIndex(of: savedFormat) {
            dateFormatPopup.selectItem(at: index)
            log("Selected format in popup: \(dateFormatPopup.titleOfSelectedItem ?? "None")", level: .debug)
        } else {
            log("Saved format not found in popup items. Available items: \(dateFormatPopup.itemTitles)", level: .warning)
            dateFormatPopup.selectItem(withTitle: NamingFormat.setting01.displayName)
        }
        
        dateFormatPopup.target = self
        dateFormatPopup.action = #selector(dateFormatChanged(_:))

        // Adjust appearance to match the desired style
        dateFormatPopup.bezelStyle = .inline
        dateFormatPopup.isBordered = false
        dateFormatPopup.font = NSFont.systemFont(ofSize: 13)
        dateFormatPopup.controlSize = .regular

        if let cell = dateFormatPopup.cell as? NSPopUpButtonCell {
            cell.arrowPosition = .arrowAtBottom
            
            // Set background color using color asset
            cell.backgroundColor = NSColor(named: "ContainerInnerBackground")
            
            // Set text color for all items
            for index in 0..<dateFormatPopup.numberOfItems {
                if let item = dateFormatPopup.item(at: index) {
                    item.attributedTitle = NSAttributedString(string: item.title, attributes: [.foregroundColor: NSColor.labelColor])
                }
            }
            
            // Update the main button title
            cell.attributedTitle = NSAttributedString(string: dateFormatPopup.titleOfSelectedItem ?? "", attributes: [.foregroundColor: NSColor.labelColor])
        }

        // Custom drawing to achieve the desired look
        dateFormatPopup.wantsLayer = true
        dateFormatPopup.layer?.cornerRadius = 6
        dateFormatPopup.layer?.masksToBounds = true

        // Add custom view for hover effect
        let customView = NSView(frame: dateFormatPopup.bounds)
        customView.wantsLayer = true
        customView.layer?.cornerRadius = 6
        customView.layer?.masksToBounds = true
        dateFormatPopup.addSubview(customView)
        
        // Move the custom view to the back
        if let index = dateFormatPopup.subviews.firstIndex(of: customView) {
            dateFormatPopup.subviews.remove(at: index)
            dateFormatPopup.subviews.insert(customView, at: 0)
        }

        // Add tracking area for hover effect
        let trackingArea = NSTrackingArea(rect: customView.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: ["view": customView])
        customView.addTrackingArea(trackingArea)

        // Add notification observer for when the popup opens
        NotificationCenter.default.addObserver(forName: NSPopUpButton.willPopUpNotification, object: dateFormatPopup, queue: nil) { _ in
            dateFormatPopup.layer?.borderWidth = 1
            dateFormatPopup.layer?.borderColor = NSColor(named: "ContainerBorder")?.cgColor
        }

        // Add notification observer for when the menu tracking ends (popup closes)
        NotificationCenter.default.addObserver(forName: NSMenu.didEndTrackingNotification, object: dateFormatPopup.menu, queue: nil) { _ in
            dateFormatPopup.layer?.borderWidth = 0
        }

        mainContainer.addSubview(dateFormatPopup)

        // Add logic for toggles
        dockToggle.action = #selector(dockToggleChanged(_:))
        dockToggle.target = self
        menuBarToggle.action = #selector(menuBarToggleChanged(_:))
        menuBarToggle.target = self

        // Adjust the content size and min/max sizes of the window
        window.isRestorable = false
        window.setContentSize(NSSize(width: 600, height: 205))
        window.minSize = NSSize(width: 600, height: 205)
        window.maxSize = NSSize(width: 600, height: 205)

        return window
    }

    @objc func dockToggleChanged(_ sender: NSSwitch) {
        if sender.state == .off {
            // If dock toggle is turned off, ensure menu bar toggle is on
            showInMenuBar = true
            
            // Schedule the re-opening of the settings window
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.reopenSettingsWindow()
            }
        }
    }

    private func reopenSettingsWindow() {
        // Close the current settings window
        settingsWindowController?.close()
        
        // Create a new settings window and show it
        settingsWindow = createSettingsWindow()
        settingsWindowController = NSWindowController(window: settingsWindow)
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func menuBarToggleChanged(_ sender: NSSwitch) {
        if sender.state == .off && !showInDock {
            // If menu bar toggle is turned off and dock is not shown, turn on dock
            showInDock = true
        }
    }

    @objc func dateFormatChanged(_ sender: NSPopUpButton) {
        if let selectedItem = sender.selectedItem,
           let format = NamingFormat.allCases.first(where: { $0.displayName == selectedItem.title }) {
            log("Saving new naming format: \(format.rawValue)", level: .debug)
            savedNamingFormat = format
            UserDefaults.standard.set(format.rawValue, forKey: selectedNamingFormatKey)
            UserDefaults.standard.synchronize()
        }
    }

    /// Creates a label with specified text, font size, weight, and color.
    ///
    /// - Parameters:
    ///   - text: The string to display in the label.
    ///   - fontSize: The size of the font to use.
    ///   - bold: A boolean indicating whether the font should be bold. Defaults to false.
    ///   - color: The color of the text. Defaults to .labelColor.
    ///
    /// - Returns: A configured NSTextField instance representing the label.
    func createLabel(text: String, fontSize: CGFloat, bold: Bool = false, color: NSColor = .labelColor) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = bold ? NSFont.boldSystemFont(ofSize: fontSize) : NSFont.systemFont(ofSize: fontSize)
        label.textColor = color
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        return label
    }

    /// Creates a toggle switch control.
    ///
    /// - Parameter frame: The frame rectangle for the switch.
    ///
    /// - Returns: A configured NSSwitch instance.
    func createToggleSwitch(frame: NSRect) -> NSSwitch {
        let toggle = NSSwitch(frame: frame)
        toggle.controlSize = .small
        return toggle
    }

    /// Creates a popup button control.
    ///
    /// - Parameter frame: The frame rectangle for the popup button.
    ///
    /// - Returns: A configured NSPopUpButton instance.
    func createPopUpButton(frame: NSRect) -> NSPopUpButton {
        let popup = NSPopUpButton(frame: frame, pullsDown: false)
        popup.controlSize = .regular
        return popup
    }

    // Add these methods to your AppDelegate class
    @objc func mouseEntered(with event: NSEvent) {
        if let view = event.trackingArea?.userInfo?["view"] as? NSView {
            view.layer?.backgroundColor = NSColor(named: "ContainerInnerBackgroundButton")?.withAlphaComponent(0.5).cgColor
        }
    }

    @objc func mouseExited(with event: NSEvent) {
        if let view = event.trackingArea?.userInfo?["view"] as? NSView {
            view.layer?.backgroundColor = .clear
        }
    }

    // Don't forget to remove the observers when appropriate, e.g., in deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Checks if the string matches a given regular expression pattern.
    ///
    /// This method uses Swift's built-in regular expression support to determine
    /// if the string contains a match for the provided regex pattern.
    ///
    /// - Parameter regex: A string representing the regular expression pattern to match against.
    ///
    /// - Returns: A boolean value indicating whether the string matches the regex pattern.
    ///   Returns `true` if a match is found, `false` otherwise.
    ///
    /// - Note: This method uses the `.regularExpression` option for pattern matching,
    ///   which means the `regex` parameter should be a valid regular expression pattern.
    ///
    /// - Important: This method does not throw exceptions for invalid regex patterns.
    ///   If an invalid pattern is provided, the method will likely return `false`.
extension String {
    
    func matches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

/// A custom NSView subclass that represents a toggle switch with a title.
///
/// This view combines a text label and an NSSwitch to create a toggleable control
/// with a descriptive title. It's designed for use in menu items or other UI elements
/// where a labeled on/off switch is needed.
///
/// - Note: This view uses Auto Layout for its internal layout.
class ToggleView: NSView {
    /// The text field displaying the titlof the toggle.
    private var titleField: NSTextField!
    
    /// The switch control for toggling the state.
    private var toggleSwitch: NSSwitch!
    
    /// The current state of the toggle.
    ///
    /// Setting this property updates the visual state of the switch.
    var isOn: Bool {
        didSet {
            updateToggleState()
        }
    }

    /// Initializes a new ToggleView with the specified title, initial state, target, and action.
    ///
    /// - Parameters:
    ///   - title: The string to display as the label for the toggle.
    ///   - isOn: The initial state of the toggle (true for on, false for off).
    ///   - target: The target object that will receive action messages when the switch is toggled.
    ///   - action: The action method to be called on the target when the switch is toggled.
    ///
    /// - Note: The view is initialized with a fixed size of 250x30 points.
    init(title: String, isOn: Bool, target: AnyObject?, action: Selector?) {
        self.isOn = isOn
        super.init(frame: NSRect(x: 0, y: 0, width: 250, height: 30))

        titleField = NSTextField(labelWithString: title)
        titleField.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        titleField.textColor = .labelColor
        titleField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleField)

        toggleSwitch = NSSwitch()
        toggleSwitch.target = target
        toggleSwitch.action = action
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            titleField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleField.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            toggleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        updateToggleState()
    }

    /// Required initializer for NSCoder. Not implemented for this class.
    ///
    /// - Parameter coder: An NSCoder instance.
    /// - Throws: A fatal error if this initializer is called.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the visual state of the toggle switch to match the `isOn` property.
    private func updateToggleState() {
        toggleSwitch.state = isOn ? .on : .off
    }

    /// Called when the view is moved to a window.
    ///
    /// This method ensures that the toggle state is updated when the view becomes visible.
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateToggleState()
    }
}

extension Array where Element: Hashable {
    /// Removes duplicate elements from the array while preserving the original order.
    ///
    /// This method creates a new array containing only the unique elements from the original array,
    /// maintaining the order in which they first appeared.
    ///
    /// - Returns: A new array containing only the unique elements from the original array.
    ///
    /// - Complexity: O(n), where n is the number of elements in the array.
    ///
    /// - Note: This method uses a dictionary to track unique elements, which may have memory implications
    ///         for very large arrays.
    ///
    /// - Important: The `Element` type must conform to `Hashable` for this method to work correctly.
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
