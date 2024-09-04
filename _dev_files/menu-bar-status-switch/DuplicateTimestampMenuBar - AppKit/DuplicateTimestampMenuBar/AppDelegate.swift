import Cocoa
import UserNotifications

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

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
    
class FileSystemWatcher {
    private var sources: [DispatchSourceFileSystemObject] = []
    private let callback: (String) -> Void
    private let queue: DispatchQueue

    init?(paths: [String], callback: @escaping (String) -> Void) {
        self.callback = callback
        self.queue = DispatchQueue(label: "com.example.FileSystemWatcher", qos: .utility)

        var success = false
        for path in paths {
            log("Setting up watcher for path: \(path)")
            let fd = open(path, O_EVTONLY)
            if fd < 0 {
                log("Error: Failed to open file descriptor for path: \(path)", level: .error)
                continue
            }
            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write, .link, .rename, .attrib], queue: queue)
            source.setEventHandler { [weak self] in
                let flags = source.data
                self?.handleFileSystemEvent(flags: flags, path: path)
            }
            source.setCancelHandler {
                close(fd)
            }
            source.resume()
            sources.append(source)
            log("Watcher set up for path: \(path)")
            success = true
        }

        if !success {
            log("Failed to set up any watchers", level: .error)
            return nil
        }
    }

    private func handleFileSystemEvent(flags: DispatchSource.FileSystemEvent, path: String) {
        log("File system event detected: \(flags) on path: \(path)")
        if flags.contains(.write) || flags.contains(.link) || flags.contains(.rename) || flags.contains(.attrib) {
            DispatchQueue.main.async {
                self.callback(path)
            }
        }
    }

    func stopWatching() {
        for source in sources {
            source.cancel()
        }
        sources.removeAll()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    var statusItem: NSStatusItem?
    var isEnabled = false {
        didSet {
            updateStatusItemIcon()
            UserDefaults.standard.set(isEnabled, forKey: "IsEnabled")
        }
    }
    private var fileSystemWatcher: FileSystemWatcher?
    var isDebugMode = false
    var debugWindow: NSWindow?
    private var desktopBookmark: Data?
    private var documentsBookmark: Data?

    override init() {
        super.init()
        log("AppDelegate initialized")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        print("Application did finish launching")
        
        testLogging()
        
        setupStatusItem()
        setupMenu()
        checkInitialState()
        
        if !verifyFolderAccess() {
            log("No access to watched folders, requesting permission")
            requestPermission()
        } else if isEnabled {
            startWatching()
        }
        
        testLogWriting()
        
        log("Application launched successfully", level: .info)
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.action = #selector(toggleMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.wantsLayer = true
        }
        log("Status item set up")
    }

    func setupMenu() {
        let menu = NSMenu()

        let customMenuItem = NSMenuItem()
        let customView = ToggleView(title: "Duplicate + Timestamp", isOn: isEnabled, target: self, action: #selector(toggleFeature))
        customMenuItem.view = customView
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

    func checkInitialState() {
        isEnabled = UserDefaults.standard.bool(forKey: "IsEnabled")
        log("Initial state: \(isEnabled ? "enabled" : "disabled")")
        updateStatusItemIcon()
        if isEnabled {
            startWatching()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        log("Application will terminate")
        stopWatching()
        stopAccessingSecurityScopedResources(for: resolveBookmarks())
    }

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

    @objc func toggleMenu() {
        log("Menu toggled")
        statusItem?.button?.performClick(nil)
    }

    @objc func toggleFeature(_ sender: NSSwitch) {
        log("Toggle feature called")
        isEnabled = sender.state == .on
        log("Feature toggled: \(isEnabled ? "enabled" : "disabled")")
        updateStatusItemIcon()
        if isEnabled {
            startWatching()
        } else {
            stopWatching()
        }
    }

    func startWatching() {
        log("Starting file watching")
        if !verifyFolderAccess() {
            log("No access to watched folders, requesting permission")
            requestPermission()
            return
        }
        
        let watchedPaths = getWatchedPaths()
        
        if watchedPaths.isEmpty {
            log("No watched paths available. Unable to start file watching.", level: .error)
            sendNotification(title: "DuplicateFileManager", message: "No folders to watch. Please check settings.")
            return
        }
        
        fileSystemWatcher = FileSystemWatcher(paths: watchedPaths, callback: { [weak self] path in
            log("File system event detected on path: \(path)")
            self?.checkForNewFiles(in: path)
        })
        
        if fileSystemWatcher == nil {
            log("Failed to initialize FileSystemWatcher", level: .error)
            sendNotification(title: "DuplicateFileManager", message: "Failed to start file watching")
        } else {
            log("FileSystemWatcher initialized successfully")
            sendNotification(title: "DuplicateFileManager", message: "File watching started")
        }
    }

    func stopWatching() {
        log("Stopping file watching")
        fileSystemWatcher?.stopWatching()
        fileSystemWatcher = nil
        sendNotification(title: "DuplicateFileManager", message: "File watching stopped")
    }
    
    func getWatchedPaths() -> [String] {
        var paths: [String] = []
        
        if let desktopURL = UserDefaults.standard.url(forKey: "SelectedDesktopURL") {
            paths.append(desktopURL.path)
            log("Desktop path: \(desktopURL.path)")
        } else {
            log("No saved Desktop path")
        }
        
        if let documentsURL = UserDefaults.standard.url(forKey: "SelectedDocumentsURL") {
            paths.append(documentsURL.path)
            log("Documents path: \(documentsURL.path)")
        } else {
            log("No saved Documents path")
        }
        
        let uniquePaths = paths.removingDuplicates()
        log("Watched paths: \(uniquePaths)")
        return uniquePaths
    }

    private func checkForNewFiles(in directory: String) {
        log("Checking for new files in directory: \(directory)")
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: directory)
            let newFiles = contents.filter { fileName in
                fileName.lowercased().contains("copy") || fileName.contains(" 2.")
            }
            
            for fileName in newFiles {
                let fullPath = (directory as NSString).appendingPathComponent(fileName)
                log("New copy file detected: \(fullPath)")
                renameFile(at: fullPath)
            }
        } catch {
            log("Error checking directory contents: \(error)", level: .error)
        }
    }

    public func renameFile(at file: String) {
        log("Attempting to rename file: \(file)")

        let url = URL(fileURLWithPath: file)
        let dir = url.deletingLastPathComponent().path
        let fileExtension = url.pathExtension
        let name = url.deletingPathExtension().lastPathComponent

        let timestamp = formattedTimestamp()
        let newName = "\(name)-\(timestamp).\(fileExtension)"

        let newPath = (dir as NSString).appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(atPath: file, toPath: newPath)
            log("Successfully renamed: \(file) to \(newPath)")
        } catch {
            log("Error renaming file: \(error.localizedDescription)", level: .error)
        }
    }

    public func formattedTimestamp() -> String {
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

    func requestFolderAccess(for url: URL, name: String) -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Please select your \(name) folder"
        openPanel.directoryURL = url
        openPanel.prompt = "Select \(name)"
        
        if openPanel.runModal() == .OK, let selectedURL = openPanel.url {
            UserDefaults.standard.set(selectedURL, forKey: "Selected\(name)URL")
            log("\(name) folder selected: \(selectedURL.path)")
            return true
        } else {
            log("No \(name) folder selected")
            return false
        }
    }

    func showAccessDeniedAlert() {
        log("Failed to gain access to watched folders", level: .error)
        let failureAlert = NSAlert()
        failureAlert.messageText = "Access Denied"
        failureAlert.informativeText = "Failed to gain access to the Desktop and Documents folders. Please check your system preferences and try again."
        failureAlert.alertStyle = .critical
        failureAlert.runModal()
    }
    
    func requestPermission() {
        log("Requesting permission for Desktop and Documents folders")
        
        let desktopAccess = requestFolderAccess(for: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop"), name: "Desktop")
        let documentsAccess = requestFolderAccess(for: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents"), name: "Documents")
        
        if desktopAccess || documentsAccess {
            if verifyFolderAccess() {
                log("Folder access verified, starting file watching")
                startWatching()
            } else {
                log("Folder access verification failed", level: .error)
                showAccessDeniedAlert()
            }
        } else {
            log("User didn't select any folders. Desktop: \(desktopAccess), Documents: \(documentsAccess)", level: .warning)
            showAccessDeniedAlert()
        }
    }

    private func createAndStoreBookmarks(desktop: URL, documents: URL) {
        log("Creating and storing bookmarks for Desktop and Documents")
        do {
            desktopBookmark = try desktop.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            documentsBookmark = try documents.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            UserDefaults.standard.set(desktopBookmark, forKey: "DesktopBookmark")
            UserDefaults.standard.set(documentsBookmark, forKey: "DocumentsBookmark")
            
            log("Bookmarks created and stored successfully")
        } catch {
            log("Error creating bookmarks: \(error.localizedDescription)", level: .error)
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

    private func resolveBookmarks() -> [URL] {
        log("Resolving bookmarks")
        var resolvedURLs: [URL] = []

        for key in ["DesktopBookmark", "DocumentsBookmark"] {
            if let bookmarkData = UserDefaults.standard.data(forKey: key) {
                do {
                    var isStale = false
                    let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    
                    if isStale {
                        log("Bookmark for \(key) is stale", level: .warning)
                        // Here you might want to request new permission and create a new bookmark
                    } else {
                        resolvedURLs.append(url)
                    }
                } catch {
                    log("Error resolving bookmark for \(key): \(error.localizedDescription)", level: .error)
                }
            } else {
                log("No bookmark data found for \(key)", level: .warning)
            }
        }

        return resolvedURLs
    }

    func stopAccessingSecurityScopedResources(for urls: [URL]) {
        for url in urls {
            url.stopAccessingSecurityScopedResource()
            log("Stopped accessing security-scoped resource: \(url.path)")
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
}

extension String {
    func matches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

class ToggleView: NSView {
    private var titleField: NSTextField!
    private var toggleSwitch: NSSwitch!

    init(title: String, isOn: Bool, target: AnyObject?, action: Selector?) {
        super.init(frame: NSRect(x: 0, y: 0, width: 250, height: 30))

        titleField = NSTextField(labelWithString: title)
        titleField.font = NSFont.systemFont(ofSize: 13)
        titleField.textColor = .labelColor
        titleField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleField)

        toggleSwitch = NSSwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.target = target
        toggleSwitch.action = action
        toggleSwitch.state = isOn ? .on : .off
        addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            titleField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleField.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            toggleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
