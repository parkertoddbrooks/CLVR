import Cocoa

@main
class DuplicateTimestampMenuBarApp: NSObject, NSApplicationDelegate {
    
    let appDelegate = AppDelegate()
    
    override init() {
        super.init()
        log("DuplicateTimestampMenuBarApp initialized")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("DuplicateTimestampMenuBarApp: Application did finish launching")
        
        // Ensure the app doesn't appear in the Dock
        NSApp.setActivationPolicy(.accessory)
        
        // Set up the app delegate
        appDelegate.applicationDidFinishLaunching(aNotification)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        log("DuplicateTimestampMenuBarApp: Application will terminate")
    }
    
    static func main() {
        log("DuplicateTimestampMenuBarApp: main() called")
        let app = NSApplication.shared
        let delegate = DuplicateTimestampMenuBarApp()
        app.delegate = delegate
        log("DuplicateTimestampMenuBarApp: About to run application")
        app.run()
    }
}

