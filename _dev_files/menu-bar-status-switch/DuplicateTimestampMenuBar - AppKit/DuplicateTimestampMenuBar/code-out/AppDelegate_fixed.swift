import Cocoa
import UserNotifications
import Security

func log(_ message: String) {
    // ... [Keep existing log function implementation] ...
}

class FileSystemWatcher {
    // ... [Keep existing FileSystemWatcher implementation] ...
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
    
    var desktopBookmark: Data?
    var documentsBookmark: Data?

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
        
        accessBookmarkedFolders()
    }
    
    @objc func toggleMenu() {
        // Implement menu toggle functionality
    }
    
    func updateStatusItemIcon() {
        // Implement status item icon update
    }
    
    func setupMenu() {
        // Implement menu setup
    }
    
    func hideAppFromDock() {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func getWatchedPaths() -> [String] {
        // Implement logic to get watched paths
        return []
    }
    
    func renameFile(at path: String) {
        // Implement file renaming logic
    }
    
    func sendNotification(title: String, message: String) {
        // Implement notification sending logic
    }
    
    func requestAccess() {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            desktopBookmark = try desktopURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            documentsBookmark = try documentsURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            UserDefaults.standard.set(desktopBookmark, forKey: "DesktopBookmark")
            UserDefaults.standard.set(documentsBookmark, forKey: "DocumentsBookmark")
            
            startWatching()
        } catch {
            log("Failed to create bookmarks: \(error)")
            // Show an alert to the user
        }
    }

    func accessBookmarkedFolders() {
        guard let desktopBookmark = UserDefaults.standard.data(forKey: "DesktopBookmark"),
              let documentsBookmark = UserDefaults.standard.data(forKey: "DocumentsBookmark") else {
            requestAccess()
            return
        }

        do {
            var isStale = false
            let desktopURL = try URL(resolvingBookmarkData: desktopBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            let documentsURL = try URL(resolvingBookmarkData: documentsBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)

            if isStale {
                requestAccess()
                return
            }

            if desktopURL.startAccessingSecurityScopedResource() && documentsURL.startAccessingSecurityScopedResource() {
                startWatching()
            } else {
                log("Failed to access bookmarked folders")
                requestAccess()
            }
        } catch {
            log("Error resolving bookmarks: \(error)")
            requestAccess()
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
}

class ToggleView: NSView {
    // ... [Keep existing ToggleView implementation] ...
}
