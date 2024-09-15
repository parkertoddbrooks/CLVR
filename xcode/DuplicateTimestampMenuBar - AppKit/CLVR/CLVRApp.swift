import Cocoa

@main
class CLVRApp: NSObject, NSApplicationDelegate {
    
    let appDelegate = AppDelegate()
    
    override init() {
        super.init()
        log("CLVRApp initialized")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("CLVRApp: Application did finish launching")
        
        // Ensure the app doesn't appear in the Dock
        NSApp.setActivationPolicy(.accessory)
        
        // Set up the app delegate
        appDelegate.applicationDidFinishLaunching(aNotification)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        log("CLVRApp: Application will terminate")
    }
    
    static func main() {
        log("CLVRApp: main() called")
        let app = NSApplication.shared
        let delegate = CLVRApp()
        app.delegate = delegate
        log("CLVRApp: About to run application")
        app.run()
    }
}

