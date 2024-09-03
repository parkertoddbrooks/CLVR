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
            let fd = open(path, O_EVTONLY)
            if fd >= 0 {
                let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .all, queue: queue)
                source.setEventHandler { [weak self] in
                    let flags = source.data
                    if flags.contains(.write) || flags.contains(.create) || flags.contains(.rename) {
                        self?.checkForNewFiles(in: path)
                    }
                }
                source.setCancelHandler {
                    close(fd)
                }
                source.resume()
                sources.append(source)
            } else {
                log("Error: Failed to open file descriptor for path: \(path)")
            }
        }
    }

    private func checkForNewFiles(in directory: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.performFileCheck(in: directory)
        }
    }

    private func performFileCheck(in directory: String) {
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
                    self.callback(fullPath)
                }
            }
        }
    }

    func stopWatching() {
        sources.forEach { $0.cancel() }
        sources.removeAll()
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
        
        requestPermission()
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
    
    @objc func toggleDebugMode() {
        isDebugMode = !isDebugMode
        log("Debug mode \(isDebugMode ? "enabled" : "disabled")")
        // Update UI to reflect debug mode status
        if let menuItem = statusItem?.menu?.item(withTitle: "Toggle Debug Mode") {
            menuItem.state = isDebugMode ? .on : .off
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
    
    func getWatchedPaths() -> [String] {
        let fileManager = FileManager.default
        var paths: [String] = []
        
        if let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first {
            paths.append(desktopURL.path)
        }
        
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            paths.append(documentsURL.path)
        }
        
        return paths
    }
    
    func renameFile(at file: String) {
        log("Detected new file: \(file)")
        
        let url = URL(fileURLWithPath: file)
        let dir = url.deletingLastPathComponent().path
        let filename = url.lastPathComponent
        let fileExtension = url.pathExtension
        var name = url.deletingPathExtension().lastPathComponent
        
        let timestamp = formattedTimestamp()
        
        if name.lowercased().hasSuffix(" copy") {
            name = name.replacingOccurrences(of: " copy", with: "", options: [.caseInsensitive, .anchored])
            let newName = "\(name)-copy-\(timestamp).\(fileExtension)"
            moveFile(from: file, to: (dir as NSString).appendingPathComponent(newName))
        } else if let range = name.range(of: "-copy-\\d{4}-\\d{2}-\\d{2}-\\d{6}(--\\d{4}-\\d{2}-\\d{2}-\\d{6})*$", options: .regularExpression) {
            let baseName = String(name[..<range.lowerBound])
            let newName = "\(baseName)-copy-\(timestamp).\(fileExtension)"
            moveFile(from: file, to: (dir as NSString).appendingPathComponent(newName))
        } else {
            log("File does not match renaming criteria: \(file)")
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
                log("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    func requestPermission() {
        let alert = NSAlert()
        alert.messageText = "Permission Required"
        alert.informativeText = "This app needs access to your Desktop and Documents folders to monitor and rename duplicated files. Do you want to grant access?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Grant Access")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
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
        } else {
            log("Permission denied to access Desktop and Documents folders")
        }
    }
    
    func verifyFolderAccess() -> Bool {
        let paths = getWatchedPaths()
        for path in paths {
            if !FileManager.default.isReadableFile(atPath: path) {
                return false
            }
        }
        return true
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