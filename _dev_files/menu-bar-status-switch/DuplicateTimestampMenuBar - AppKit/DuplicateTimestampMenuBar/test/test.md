import Cocoa
import QuartzCore
import Foundation
import Dispatch

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

class FileSystemWatcher {
    private let queue = DispatchQueue(label: "com.example.FileSystemWatcher", attributes: .concurrent)
    private var source: DispatchSourceFileSystemObject?
    private let path: String
    private let callback: (String) -> Void

    init(path: String, callback: @escaping (String) -> Void) {
        self.path = path
        self.callback = callback
    }

    func startWatching() {
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)
        source?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.callback(self.path)
        }
        source?.setCancelHandler {
            close(fileDescriptor)
        }
        source?.resume()
    }

    func stopWatching() {
        source?.cancel()
    }
}

class AppDelegate: NSObject {
    var statusItem: NSStatusItem?
    var isEnabled = true {
        didSet {
            updateStatusItemIcon()
        }
    }
    private var desktopWatcher: FileSystemWatcher?
    private var documentsWatcher: FileSystemWatcher?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.action = #selector(toggleMenu)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.wantsLayer = true
        }
        
        updateStatusItemIcon()
        setupMenu()
        hideAppFromDock()
    }

    func wiggleStatusItemIcon() {
        guard let button = statusItem?.button else { return }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, 2, -2, 1.5, -1.5, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.duration = 1.0
        animation.isAdditive = true
        
        button.layer?.add(animation, forKey: "wiggle.right.byLayer")
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        let customMenuItem = NSMenuItem()
        let customView = ToggleView(title: "Duplicate + Timestamp", isOn: true, target: self, action: #selector(toggleFeature))
        customMenuItem.view = customView
        menu.addItem(customMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc func toggleMenu() {
        statusItem?.button?.performClick(nil)
    }
    
    @objc func toggleFeature(_ sender: NSSwitch) {
        isEnabled = sender.state == .on
        updateStatusItemIcon()
        duplicateAndTimestamp()
    }
    
    func duplicateAndTimestamp() {
        if isEnabled {
            startWatching()
        } else {
            stopWatching()
        }
    }

    func startWatching() {
        log("Starting file system watchers")
        desktopWatcher = FileSystemWatcher(path: NSHomeDirectory() + "/Desktop") { [weak self] path in
            self?.handleFileChange(path: path)
        }
        documentsWatcher = FileSystemWatcher(path: NSHomeDirectory() + "/Documents") { [weak self] path in
            self?.handleFileChange(path: path)
        }
        desktopWatcher?.startWatching()
        documentsWatcher?.startWatching()
    }

    func stopWatching() {
        log("Stopping file system watchers")
        desktopWatcher?.stopWatching()
        documentsWatcher?.stopWatching()
    }

    func handleFileChange(path: String) {
        log("File change detected at: \(path)")
        // Implement file renaming logic here
    }

    func log(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        print("[\(timestamp)] \(message)")
    }
    
    func updateStatusItemIcon() {
        let iconName = isEnabled ? "doc.on.doc.fill" : "doc.on.doc"
        let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Duplicate")
        image?.isTemplate = true
        statusItem?.button?.image = image
        wiggleStatusItemIcon()
    }
    
    func hideAppFromDock() {
        NSApp.setActivationPolicy(.accessory)
    }
}