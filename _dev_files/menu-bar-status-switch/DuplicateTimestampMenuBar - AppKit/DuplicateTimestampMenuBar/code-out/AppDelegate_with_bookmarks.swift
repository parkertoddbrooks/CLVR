import Cocoa
import UserNotifications
import Security

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
    // ... [Keep the existing FileSystemWatcher implementation] ...
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
    
    // New properties for security-scoped bookmarks
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
        
        // Use the new access method
        accessBookmarkedFolders()
    }
    
    // ... [Keep other existing methods] ...

    // New method to request access using security-scoped bookmarks
    func requestAccess() {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            desktopBookmark = try desktopURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            documentsBookmark = try documentsURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            // Save bookmarks to UserDefaults
            UserDefaults.standard.set(desktopBookmark, forKey: "DesktopBookmark")
            UserDefaults.standard.set(documentsBookmark, forKey: "DocumentsBookmark")
            
            startWatching()
        } catch {
            log("Failed to create bookmarks: \(error)")
            // Show an alert to the user
            let alert = NSAlert()
            alert.messageText = "Permission Error"
            alert.informativeText = "Failed to gain access to the Desktop and Documents folders. Please check your system preferences and try again."
            alert.alertStyle = .critical
            alert.runModal()
        }
    }

    // New method to access bookmarked folders
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

    // Modified startWatching method
    func startWatching() {
        let watchedPaths = getWatchedPaths()
        
        log("Starting file system watchers for paths: \(watchedPaths)")
        fileSystemWatcher = FileSystemWatcher(paths: watchedPaths) { [weak self] path in
            self?.renameFile(at: path)
        }
        sendNotification(title: "DuplicateFileManager", message: "File watching started")
    }

    // ... [Keep other existing methods] ...

    // Replace the old requestPermission method with this one
    func requestPermission() {
        let alert = NSAlert()
        alert.messageText = "Permission Required"
        alert.informativeText = "This app needs access to your Desktop and Documents folders. Please grant access in the next dialog."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            requestAccess()
        } else {
            log("Permission denied to access Desktop and Documents folders")
        }
    }

    // ... [Keep other existing methods] ...
}

// ... [Keep ToggleView class implementation] ...