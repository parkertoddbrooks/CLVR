import Cocoa
import UserNotifications

func log(_ message: String) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = dateFormatter.string(from: Date())
    let logMessage = "[\(timestamp)] \(message)\n"

    let logFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/log/DuplicateWithTimestamp.log")

    do {
        if FileManager.default.fileExists(atPath: logFile.path) {
            let fileHandle = try FileHandle(forWritingTo: logFile)
            fileHandle.seekToEndOfFile()
            fileHandle.write(logMessage.data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try logMessage.write(to: logFile, atomically: true, encoding: .utf8)
        }
    } catch {
        print("Error writing to log file: \(error.localizedDescription)")
    }
}

class FileSystemWatcher {
    private var sources: [DispatchSourceFileSystemObject] = []
    private let callback: (String) -> Void
    private let queue: DispatchQueue
    private var debounceTimer: Timer?

    init(paths: [String], callback: @escaping (String) -> Void) {
        self.callback = callback
        self.queue = DispatchQueue(label: "com.example.FileSystemWatcher", qos: .utility)

        for path in paths {
            log("Setting up file system watcher for path: \(path)")
            let fd = open(path, O_EVTONLY)
            if fd >= 0 {
                let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .all, queue: queue)
                source.setEventHandler { [weak self] in
                    let flags = source.data
                    self?.handleFileSystemEvent(flags: flags, path: path)
                }
                source.setCancelHandler {
                    close(fd)
                }
                source.resume()
                sources.append(source)
                log("File system watcher set up successfully for path: \(path)")
            } else {
                log("Error: Failed to open file descriptor for path: \(path)")
            }
        }
    }

    private func handleFileSystemEvent(flags: DispatchSource.FileSystemEvent, path: String) {
        var events: [String] = []
        if flags.contains(.write) { events.append("write") }
        if flags.contains(.extend) { events.append("extend") }
        if flags.contains(.attrib) { events.append("attrib") }
        if flags.contains(.link) { events.append("link") }
        if flags.contains(.rename) { events.append("rename") }
        if flags.contains(.revoke) { events.append("revoke") }
        
        log("File system event detected: \(events.joined(separator: ", ")) on path: \(path)")
        checkForNewFiles(in: path)
    }

    private func checkForNewFiles(in directory: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.performFileCheck(in: directory)
        }
    }

    private func performFileCheck(in directory: String) {
        log("Performing file check in directory: \(directory)")
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: directory)
        let currentDate = Date()

        while let filePath = enumerator?.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            if let attributes = try? fileManager.attributesOfItem(atPath: fullPath),
               let creationDate = attributes[.creationDate] as? Date,
               let modificationDate = attributes[.modificationDate] as? Date {

                // Check if the file was created or modified in the last second
                if currentDate.timeIntervalSince(creationDate) < 1 || currentDate.timeIntervalSince(modificationDate) < 1 {
                    log("New or modified file detected: \(fullPath)")
                    self.callback(fullPath)
                }
            }
        }
        log("File check completed in directory: \(directory)")
    }

    func stopWatching() {
        log("Stopping file system watchers")
        sources.forEach { $0.cancel() }
        sources.removeAll()
        log("All file system watchers stopped")
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        log("Application launched")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.action = #selector(toggleMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.wantsLayer = true
        }

        isEnabled = UserDefaults.standard.bool(forKey: "IsEnabled")
        updateStatusItemIcon()
        setupMenu()
        hideAppFromDock()

        if !verifyFolderAccess() {
            requestPermission()
        } else if isEnabled {
            startWatching()
        }

        setupDebugWindow()
    }

    func setupDebugWindow() {
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
        // Update UI to reflect debug mode status
        if let menuItem = statusItem?.menu?.item(withTitle: "Toggle Debug Mode") {
            menuItem.state = isDebugMode ? .on : .off
        }
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
    }

    @objc func toggleMenu() {
        statusItem?.button?.performClick(nil)
    }

    @objc func toggleFeature(_ sender: NSSwitch) {
        isEnabled = sender.state == .on
        log("Toggle state changed to: \(isEnabled)")
        updateStatusItemIcon()
        if isEnabled {
            startWatching()
        } else {
            stopWatching()
        }
    }

    func startWatching() {
        let watchedPaths = getWatchedPaths()

        log("Starting file system watchers for paths: \(watchedPaths)")
        fileSystemWatcher = FileSystemWatcher(paths: watchedPaths) { [weak self] path in
            self?.renameFile(at: path)
        }
        sendNotification(title: "DuplicateFileManager", message: "File watching started")
    }

    func stopWatching() {
        log("Stopping file system watchers")
        fileSystemWatcher?.stopWatching()
        fileSystemWatcher = nil
        sendNotification(title: "DuplicateFileManager", message: "File watching stopped")
    }

    public func getWatchedPaths() -> [String] {
        return resolveBookmarks().map { $0.path }
    }

    public func renameFile(at file: String) -> String {
        log("Detected new file: \(file)")

        let url = URL(fileURLWithPath: file)
        let dir = url.deletingLastPathComponent().path
        let fileExtension = url.pathExtension
        var name = url.deletingPathExtension().lastPathComponent

        let timestamp = formattedTimestamp()

        if name.lowercased().hasSuffix(" copy") {
            name = name.replacingOccurrences(of: " copy", with: "", options: [.caseInsensitive, .anchored])
            let newName = "\(name)-copy-\(timestamp).\(fileExtension)"
            let newPath = (dir as NSString).appendingPathComponent(newName)
            moveFile(from: file, to: newPath)
            return newPath
        } else if let range = name.range(of: "-copy-\\d{4}-\\d{2}-\\d{2}-\\d{6}(--\\d{4}-\\d{2}-\\d{2}-\\d{6})*$", options: .regularExpression) {
            let baseName = String(name[..<range.lowerBound])
            let newName = "\(baseName)-copy-\(timestamp).\(fileExtension)"
            let newPath = (dir as NSString).appendingPathComponent(newName)
            moveFile(from: file, to: newPath)
            return newPath
        } else {
            log("File does not match renaming criteria: \(file)")
            return file
        }
    }

    private func moveFile(from oldPath: String, to newPath: String) {
        do {
            try FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
            log("Successfully renamed: \(oldPath) to \(newPath)")
        } catch {
            log("Error: Failed to rename \(oldPath): \(error.localizedDescription)")
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
                log("Error sending notification: \(error.localizedDescription)")
            }
        }
    }

    func requestPermission() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Please select your Desktop folder"
        openPanel.prompt = "Select Desktop"
        
        if openPanel.runModal() == .OK {
            guard let desktopURL = openPanel.url else {
                log("Failed to get Desktop URL")
                return
            }
            
            openPanel.message = "Please select your Documents folder"
            openPanel.prompt = "Select Documents"
            
            if openPanel.runModal() == .OK {
                guard let documentsURL = openPanel.url else {
                    log("Failed to get Documents URL")
                    return
                }
                
                createAndStoreBookmarks()
                
                if verifyFolderAccess() {
                    startWatching()
                } else {
                    log("Failed to gain access to watched folders")
                    let failureAlert = NSAlert()
                    failureAlert.messageText = "Access Denied"
                    failureAlert.informativeText = "Failed to gain access to the Desktop and Documents folders. Please check your system preferences and try again."
                    failureAlert.alertStyle = .critical
                    failureAlert.runModal()
                }
            }
        }
    }

    public func verifyFolderAccess() -> Bool {
        let urls = resolveBookmarks()
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else {
                return false
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            if !FileManager.default.isReadableFile(atPath: url.path) || !FileManager.default.isWritableFile(atPath: url.path) {
                return false
            }
        }
        return true
    }

    private func createAndStoreBookmarks() {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            desktopBookmark = try desktopURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            documentsBookmark = try documentsURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            UserDefaults.standard.set(desktopBookmark, forKey: "DesktopBookmark")
            UserDefaults.standard.set(documentsBookmark, forKey: "DocumentsBookmark")
            
            log("Bookmarks created and stored successfully")
        } catch {
            log("Error creating bookmarks: \(error.localizedDescription)")
        }
    }

    private func resolveBookmarks() -> [URL] {
            var urls: [URL] = []
            
            if let desktopBookmark = UserDefaults.standard.data(forKey: "DesktopBookmark"),
               let documentsBookmark = UserDefaults.standard.data(forKey: "DocumentsBookmark") {
               do {
                   var isStale = false
                   let desktopURL = try URL(resolvingBookmarkData: desktopBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                   urls.append(desktopURL)
                   
                   isStale = false
                   let documentsURL = try URL(resolvingBookmarkData: documentsBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                   urls.append(documentsURL)
                   
                   log("Bookmarks resolved successfully")
               } catch {
                   log("Error resolving bookmarks: \(error.localizedDescription)")
               }
           }
           
           return urls
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
