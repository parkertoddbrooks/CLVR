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
    private var stream: FSEventStreamRef?
    private let callback: (String) -> Void
    private let queue: DispatchQueue

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

    deinit {
        if let stream = stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
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
    private var previousFiles: [String: [String]] = [:]
    private var recentlyProcessedFiles: Set<String> = []

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
        
        if let savedBookmark = UserDefaults.standard.data(forKey: "DocumentsBookmark") {
            documentsBookmark = savedBookmark
        }
        
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
        stopAccessingSecurityScopedResources()
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
        let watchedPaths = getWatchedPaths()
        log("Watched paths: \(watchedPaths)")
        fileSystemWatcher = FileSystemWatcher(paths: watchedPaths) { [weak self] path in
            self?.handleFileSystemEvent(path: path)
        }
        log("FileSystemWatcher initialized")
    }

    func stopWatching() {
        log("Stopping file watching")
        fileSystemWatcher = nil
    }

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

    func shouldRenameFile(_ filename: String) -> Bool {
        let name = (filename as NSString).deletingPathExtension.lowercased()
        let hasCopySuffix = name.hasSuffix(" copy")
        let hasTimestamp = name.matches(regex: #"-copy-\d{4}-\d{2}-\d{2}-\d{6}$"#)
        
        log("Checking file: \(filename), hasCopySuffix: \(hasCopySuffix), hasTimestamp: \(hasTimestamp)")
        
        // Only rename if it has " copy" suffix and doesn't already have our timestamp
        return hasCopySuffix && !hasTimestamp
    }

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
