
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

    init(paths: [String], callback: @escaping (String) -> Void) {
        self.callback = callback
        self.queue = DispatchQueue(label: "com.example.FileSystemWatcher", qos: .utility)

        for path in paths {
            let fd = open(path, O_EVTONLY)
            if fd >= 0 {
                let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .all, queue: queue)
                source.setEventHandler { [weak self] in
                    let flags = source.data
                    if flags.contains(.write) {
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
        let enumerator = FileManager.default.enumerator(atPath: directory)
        while let filePath = enumerator?.nextObject() as? String {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            self.callback(fullPath)
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
        
        log("Starting file system watchers")
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
        
        var newName: String
        let timestamp = formattedTimestamp()
        
        if name.lowercased().hasSuffix(" copy") {
            name = name.replacingOccurrences(of: " copy", with: "", options: [.caseInsensitive, .anchored])
            newName = "\(name)-copy-\(timestamp).\(fileExtension)"
        } else if name.matches(regex: "-copy-\\d{4}-\\d{2}-\\d{2}-\\d{6}(--\\d{4}-\\d{2}-\\d{2}-\\d{6})*$") {
            newName = "\(name)--\(timestamp).\(fileExtension)"
        } else {
            log("File does not match renaming criteria: \(file)")
            return
        }
        
        let newPath = (dir as NSString).appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(atPath: file, toPath: newPath)
            log("Successfully renamed: \(file) to \(newPath)")
        } catch {
            log("Error: Failed to rename \(file): \(error.localizedDescription)")
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
            // User clicked "Grant Access"
            startWatching()
        } else {
            // User clicked "Cancel"
            log("Permission denied to access Desktop and Documents folders")
            // Optionally, you can quit the app here if permission is required
            // NSApplication.shared.terminate(self)
        }
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
