# Refactoring SwiftUI to AppKit for Native macOS Menu Bar App (v2)

## Overview
This document outlines the steps needed to refactor our SwiftUI-based menu bar app to use AppKit components for a more native macOS look and feel, with a focus on implementing NSStatusBar and NSStatusItem.

## Steps

1. Update Project Settings
   - In Xcode, select the project file
   - Under "Deployment Info", ensure "Mac" is selected
   - Set the minimum deployment target to the desired macOS version

2. Create AppDelegate
   - Create a new Swift file named `AppDelegate.swift`
   - Implement `NSApplicationDelegate` protocol
   - Set up the status item and menu

3. Implement Status Item with NSStatusBar and NSStatusItem
   - Use `NSStatusBar.system.statusItem(withLength:)` to create the status item
   - Set up the status item's button with an appropriate icon
   - Implement action for status item click

4. Create Menu Structure with NSMenu
   - Use `NSMenu` and `NSMenuItem` to create the menu structure
   - Attach the menu to the status item

5. Implement Toggle Functionality with NSMenuItem
   - Create a custom view for the "Duplicate + Timestamp" item with NSSwitch
   - Implement action for toggle state changes

6. Style Menu and Items
   - Use `NSVisualEffectView` for the menu background if needed
   - Style menu items to match system appearance

7. Implement "Quit" Functionality
   - Add a menu item for "Quit"
   - Implement action to terminate the application

8. Update Info.plist
   - Set `LSUIElement` to `true` to hide the app from the Dock

9. Remove SwiftUI Components
   - Delete the ContentView.swift file and any other SwiftUI-specific files

10. Testing and Refinement
    - Test the app thoroughly on different macOS versions
    - Refine styling and behavior to match system menus exactly

## Detailed Implementation

### AppDelegate.swift
```swift
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupMenu()
    }

    func setupStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.action = #selector(statusItemClicked(_:))
        }
    }

    func setupMenu() {
        let toggleItem = NSMenuItem(title: "Duplicate + Timestamp", action: #selector(toggleDuplicateTimestamp(_:)), keyEquivalent: "")
        toggleItem.view = createToggleView()
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

    func createToggleView() -> NSView {
        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        let toggle = NSSwitch(frame: NSRect(x: 170, y: 5, width: 30, height: 20))
        toggle.target = self
        toggle.action = #selector(toggleSwitched(_:))
        
        let label = NSTextField(labelWithString: "Duplicate + Timestamp")
        label.frame = NSRect(x: 10, y: 5, width: 150, height: 20)
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        
        customView.addSubview(label)
        customView.addSubview(toggle)
        
        return customView
    }

    @objc func statusItemClicked(_ sender: Any?) {
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }

    @objc func toggleDuplicateTimestamp(_ sender: Any?) {
        // Implement toggle functionality
    }

    @objc func toggleSwitched(_ sender: NSSwitch) {
        // Implement toggle switch action
    }
}
```

### Main.swift
```swift
import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

## Next Steps
- Implement each component step by step
- Test thoroughly after each implementation
- Refine UI and interactions to match system behavior exactly
- Update the Automator app and shell scripts to work with the new AppKit implementation
- Revise the DMG creation process if necessary

This refactoring process will result in a menu bar app that uses native AppKit components, ensuring the most authentic macOS look and feel. The use of NSStatusBar and NSStatusItem will provide a truly native menu bar experience, matching the behavior of system menu bar items like the Bluetooth menu.