# Refactoring SwiftUI to AppKit for Native macOS Menu Bar App

## Overview
This document outlines the steps needed to refactor our SwiftUI-based menu bar app to use AppKit components for a more native macOS look and feel.

## Steps

1. Update Project Settings
   - In Xcode, select the project file
   - Under "Deployment Info", ensure "Mac" is selected
   - Set the minimum deployment target to the desired macOS version

2. Create AppDelegate
   - Create a new Swift file named `AppDelegate.swift`
   - Implement `NSApplicationDelegate` protocol
   - Set up the status item and menu

3. Implement Status Item
   - Use `NSStatusBar.system.statusItem(withLength:)` to create the status item
   - Set up the status item's button with an appropriate icon

4. Create Menu Structure
   - Use `NSMenu` and `NSMenuItem` to create the menu structure
   - Implement custom view for the "Duplicate + Timestamp" item with toggle

5. Implement Toggle Functionality
   - Use `NSSwitch` for the toggle control
   - Connect toggle state changes to appropriate actions

6. Style Menu and Items
   - Use `NSVisualEffectView` for the menu background
   - Style menu items to match system appearance

7. Implement "Quit" Functionality
   - Add a menu item for "Quit"
   - Implement action to terminate the application

8. Update Info.plist
   - Set `LSUIElement` to `true` to hide the app from the Dock

9. Refactor SwiftUI Views
   - Convert any remaining SwiftUI views to AppKit equivalents
   - Use `NSHostingView` if needed to embed SwiftUI content

10. Testing and Refinement
    - Test the app thoroughly on different macOS versions
    - Refine styling and behavior to match system menus exactly

## Code Snippets

### AppDelegate.swift
```swift
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
    }

    func setupMenuBar() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
        }
        setupMenu()
    }

    func setupMenu() {
        menu.addItem(withTitle: "Duplicate + Timestamp", action: #selector(toggleDuplicateTimestamp), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }

    @objc func toggleDuplicateTimestamp() {
        // Implement toggle functionality
    }
}
```

## Next Steps
- Implement each component step by step
- Test thoroughly after each implementation
- Refine UI and interactions to match system behavior exactly

This refactoring process will result in a menu bar app that uses native AppKit components, ensuring the most authentic macOS look and feel.