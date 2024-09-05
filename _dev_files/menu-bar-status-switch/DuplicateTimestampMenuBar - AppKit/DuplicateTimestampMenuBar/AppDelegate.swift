import Cocoa
import UserNotifications

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
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
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

    /// Initializes the AppDelegate.
    override init() {
        super.init()
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
        toggleView = ToggleView(title: "Duplicate + Timestamp", isOn: isEnabled, target: self, action: #selector(toggleFeature))
        customMenuItem.view = toggleView
        menu.addItem(customMenuItem)

        menu.addItem(NSMenuItem.separator())

        let debugMenuItem = NSMenuItem(title: "Toggle Debug Mode", action: #selector(toggleDebugMode), keyEquivalent: "")
        menu.addItem(debugMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
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

    /// Sets up the debug window for displaying additional information.
    func setupDebugWindow() {
        log("Setting up debug window")
        debugWindow = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
                               styleMask: [.titled, .closable, .miniaturizable, .resizable],
                               backing: .buffered,
                               defer: false)
        debugWindow?.title = "Debug Info"
        debugWindow?.isReleasedWhenClosed = false
        
        let textView = NSTextView(frame: debugWindow!.contentView!.bounds)
        textView.isEditable = false
        textView.autoresizingMask = [.width, .height]
        debugWindow?.contentView?.addSubview(textView)
    }

    /// Toggles the debug mode on and off.
    @objc func toggleDebugMode() {
        isDebugMode = !isDebugMode
        log("Debug mode \(isDebugMode ? "enabled" : "disabled")")
        if isDebugMode {
            debugWindow?.makeKeyAndOrderFront(nil)
        } else {
            debugWindow?.orderOut(nil)
        }
        if let menuItem = statusItem?.menu?.item(withTitle: "Toggle Debug Mode") {
            menuItem.state = isDebugMode ? .on : .off
        }
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
        
        animateStatusItemIcon()
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

    /// Resolves the security-scoped bookmark for the Documents folder.
    ///
    /// - Returns: The URL of the Documents folder, or nil if resolution fails.
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

    /// Stops accessing all security-scoped resources.
    private func stopAccessingSecurityScopedResources() {
        if let documentsURL = resolveDocumentsBookmark() {
            documentsURL.stopAccessingSecurityScopedResource()
        }
    }

    /// Handles file system events.
    ///
    /// - Parameter path: The path of the file that triggered the event.
    func handleFileSystemEvent(path: String) {
        log("File system event detected: \(path)")
        
        // Check if this file was recently processed
        if recentlyProcessedFiles.contains(path) {
            log("File was recently processed, skipping: \(path)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let filename = url.lastPathComponent
        
        log("Checking if file should be renamed: \(filename)")
        if shouldRenameFile(filename) {
            log("File should be renamed, attempting to rename: \(filename)")
            renameFile(at: path)
            
            // Add the file to the recently processed set
            recentlyProcessedFiles.insert(path)
            
            // Remove the file from the set after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.recentlyProcessedFiles.remove(path)
            }
        } else {
            log("File does not need to be renamed: \(filename)")
        }
    }

    /// Determines if a file should be renamed based on its filename.
    ///
    /// - Parameter filename: The name of the file to check.
    /// - Returns: A boolean indicating whether the file should be renamed.
    func shouldRenameFile(_ filename: String) -> Bool {
        let name = (filename as NSString).deletingPathExtension.lowercased()
        let hasCopySuffix = name.hasSuffix(" copy")
        let hasTimestamp = name.matches(regex: #"-copy-\d{4}-\d{2}-\d{2}-\d{6}$"#)
        
        log("Checking file: \(filename), hasCopySuffix: \(hasCopySuffix), hasTimestamp: \(hasTimestamp)")
        
        // Only rename if it has " copy" suffix and doesn't already have our timestamp
        return hasCopySuffix && !hasTimestamp
    }

    /// Renames a file by adding a timestamp to its name.
    ///
    /// - Parameter path: The path of the file to rename.
    func renameFile(at path: String) {
        log("Attempting to rename file: \(path)")
        let url = URL(fileURLWithPath: path)
        let filename = url.lastPathComponent
        
        // Check if the file actually needs renaming
        guard shouldRenameFile(filename) else {
            log("File does not need renaming: \(filename)")
            return
        }
        
        let directory = url.deletingLastPathComponent()
        let fileExtension = url.pathExtension
        var name = (filename as NSString).deletingPathExtension

        log("File details - Name: \(name), Extension: \(fileExtension)")

        let timestamp = formattedTimestamp()
        var newName: String

        if name.lowercased().hasSuffix(" copy") {
            name = (name as NSString).substring(to: name.count - 5)
            newName = "\(name)-copy-\(timestamp).\(fileExtension)"
        } else {
            // Extract existing timestamps
            let regex = try! NSRegularExpression(pattern: #"-copy-\d{4}-\d{2}-\d{2}-\d{6}(--\d{4}-\d{2}-\d{2}-\d{6})*$"#)
            if let match = regex.firstMatch(in: name, options: [], range: NSRange(location: 0, length: name.utf16.count)) {
                let timestampStart = match.range.lowerBound
                name = (name as NSString).substring(to: timestampStart)
            }
            newName = "\(name)-copy-\(timestamp).\(fileExtension)"
        }

        log("New name: \(newName)")

        var newPath = directory.appendingPathComponent(newName).path

        // Check if the new filename already exists
        var counter = 1
        while FileManager.default.fileExists(atPath: newPath) {
            newName = "\(name)-copy-\(timestamp) (\(counter)).\(fileExtension)"
            newPath = directory.appendingPathComponent(newName).path
            counter += 1
        }

        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
            log("Successfully renamed: \(path) to \(newPath)")
            
            // Trigger the wiggle animation after successful renaming
            DispatchQueue.main.async { [weak self] in
                self?.animateStatusItemIcon()
            }
        } catch {
            log("Error renaming file: \(error.localizedDescription)", level: .error)
        }
    }

    private func formattedTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return dateFormatter.string(from: Date())
    }

    func updateStatusItemIcon() {
        let iconName = isEnabled ? "doc.on.doc.fill" : "doc.on.doc"
        let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Duplicate")
        image?.isTemplate = true
        statusItem?.button?.image = image
    }

    func hideAppFromDock() {
        NSApp.setActivationPolicy(.accessory)
    }

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
        failureAlert.messageText = "Access Denied"
        failureAlert.informativeText = "Failed to gain access to the Desktop and Documents folders. Please check your system preferences and try again."
        failureAlert.alertStyle = .critical
        failureAlert.runModal()
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

    /// Animates the status item icon with a wiggle effect.
    ///
    /// This function creates and applies a horizontal translation animation to the status item's button,
    /// creating a wiggle effect. The animation is a sequence of small left and right movements,
    /// gradually decreasing in magnitude.
    ///
    /// - Note: This function does nothing if the status item or its button is not available.
    ///
    /// - Important: This function assumes that the status item's button has a layer. If the layer
    ///   is not available, the animation will not be applied.
    func animateStatusItemIcon() {
        guard let button = statusItem?.button else { return }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-1.5, 1.5, 0, -1.5, 1.5, 0]
        animation.duration = 0.45
        animation.calculationMode = .linear
        
        button.layer?.add(animation, forKey: "doubleWiggleAnimation")
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
        titleField.font = NSFont.systemFont(ofSize: 13)
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
    /// maintaining the order in which they first appear.
    ///
    /// - Complexity: O(n), where n is the length of the array.
    ///
    /// - Returns: A new array containing only the unique elements from the original array,
    ///            preserving their original order.
    ///
    /// - Note: This method uses a dictionary to keep track of elements that have already been seen,
    ///         which allows for efficient lookup and removal of duplicates.
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
