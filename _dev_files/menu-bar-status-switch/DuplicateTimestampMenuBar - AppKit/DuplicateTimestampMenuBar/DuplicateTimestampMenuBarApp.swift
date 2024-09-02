import Cocoa

@main
class DuplicateTimestampMenuBarApp: NSObject, NSApplicationDelegate {
    
    let appDelegate = AppDelegate()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Ensure the app doesn't appear in the Dock
        NSApp.setActivationPolicy(.accessory)
        
        // Set up the app delegate
        appDelegate.applicationDidFinishLaunching(aNotification)
    }
    
    static func main() {
        let app = NSApplication.shared
        let delegate = DuplicateTimestampMenuBarApp()
        app.delegate = delegate
        app.run()
    }
}