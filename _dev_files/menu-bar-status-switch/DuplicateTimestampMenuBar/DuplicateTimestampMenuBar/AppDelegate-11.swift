import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Duplicate")
            button.action = #selector(toggleMenu)
        }

        let contentView = ContentView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 100),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window?.isReleasedWhenClosed = false
        window?.contentView = NSHostingView(rootView: contentView)
        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.hasShadow = true
        window?.level = .popUpMenu
    }
    
    @objc func toggleMenu() {
        if let window = window {
            if window.isVisible {
                window.close()
            } else {
                showMenu()
            }
        }
    }
    
    func showMenu() {
        guard let window = window, let statusItem = statusItem else { return }
        
        let statusRect = statusItem.button?.window?.convertToScreen(statusItem.button?.bounds ?? .zero) ?? .zero
        let windowRect = NSRect(x: statusRect.origin.x, y: statusRect.origin.y - window.frame.height, width: window.frame.width, height: window.frame.height)
        
        window.setFrame(windowRect, display: false)
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
}

