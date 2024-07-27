import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    @State private var isEnabled = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Duplicate")
        }
        
        setupMenus()
    }
    
    func setupMenus() {
        let menu = NSMenu()
        
        let contentView = MenuView()
        let customMenuItem = NSMenuItem()
        customMenuItem.view = NSHostingView(rootView: contentView)
        menu.addItem(customMenuItem)
        
        statusItem?.menu = menu
    }
    
    func updateMenuState() {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: isEnabled ? "doc.on.doc.fill" : "doc.on.doc", accessibilityDescription: "Duplicate")
        }
    }
}

struct MenuView: View {
    @State private var isEnabled = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Duplicate + Timestamp", isOn: $isEnabled)
                .onChange(of: isEnabled) { newValue in
                    let success = newValue ? ScriptManager.shared.startDuplicateTimestamp() : ScriptManager.shared.stopDuplicateTimestamp()
                    if !success {
                        errorMessage = "Failed to \(newValue ? "start" : "stop") Duplicate + Timestamp"
                        isEnabled.toggle() // Revert the toggle if operation failed
                    } else {
                        errorMessage = nil
                    }
                }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .background(Color(NSColor.windowBackgroundColor))
            .environment(\.colorScheme, .light)
        
        MenuView()
            .background(Color(NSColor.windowBackgroundColor))
            .environment(\.colorScheme, .dark)
    }
}

@main
struct DuplicateTimestampMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

