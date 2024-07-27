import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var isEnabled = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Duplicate")
        }
        
        setupMenus()
        updateMenuState()
    }
    
    func setupMenus() {
        let menu = NSMenu()
        
        let toggleItem = NSMenuItem(title: "Duplicate + Timestamp", action: #selector(toggleDuplicateTimestamp), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleDuplicateTimestamp() {
        let success: Bool
        if !isEnabled {
            success = ScriptManager.shared.startDuplicateTimestamp()
            if success {
                print("Duplicate + Timestamp enabled")
                isEnabled = true
            } else {
                print("Failed to enable Duplicate + Timestamp")
                self.showAlert(message: "Failed to enable Duplicate + Timestamp")
            }
        } else {
            success = ScriptManager.shared.stopDuplicateTimestamp()
            if success {
                print("Duplicate + Timestamp disabled")
                isEnabled = false
            } else {
                print("Failed to disable Duplicate + Timestamp")
                self.showAlert(message: "Failed to disable Duplicate + Timestamp")
            }
        }
        updateMenuState()
    }
    
    func updateMenuState() {
        if let menuItem = statusItem?.menu?.item(at: 0) {
            menuItem.state = isEnabled ? .on : .off
        }
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: isEnabled ? "doc.on.doc.fill" : "doc.on.doc", accessibilityDescription: "Duplicate")
        }
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
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

