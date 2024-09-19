# Project Context: Tool Bar Status and Switcher Implementation

This document provides essential context for AI assistants or co-pilots to understand and contribute to the implementation of a tool bar status and switcher for the "Duplicate File and Update Name with Timestamp" application.

## Project Overview

- Project Name: Duplicate File and Update Name with Timestamp
- Current Version: v1.2.0
- New Feature: Tool Bar Status and Switcher
- Main Implementation File: tool-bar-steps-v01.md

## Background

The "Duplicate File and Update Name with Timestamp" application is a macOS utility that automatically renames duplicated files with timestamps. The current implementation involves a background service managed by shell scripts. We are now adding a tool bar status icon and switcher to improve user interaction and control over the service.

## Current State

- The application functions as a background service.
- File renaming is handled by DuplicateFileManager.sh and DuplicateWithTimestamp.sh scripts.
- There is no graphical user interface for controlling the service.

## Goal

Implement a macOS tool bar status icon and menu that allows users to:
1. View the current status of the file renaming service (active/inactive).
2. Start and stop the service.
3. Access application settings.
4. Quit the application.

## Key Files and Their Locations

1. Main implementation steps: 
   `/Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh/duplicate-file-and-update-name-with-timestamp-sh/ai-insights/ v1-2-0/steps/tool-bar-steps-v01.md`

2. Existing shell scripts:
   - DuplicateFileManager.sh
   - DuplicateWithTimestamp.sh
   (Exact locations to be specified)

## Implementation Details

- Language: Swift (preferred) or Objective-C
- Framework: Cocoa (AppKit)
- Key Classes: NSStatusItem, NSMenu, NSMenuItem

## Next Steps

1. Set up a new Xcode project for the tool bar application.
2. Implement the NSStatusItem with custom icons for active and inactive states.
3. Create the menu structure with items for start/stop, settings, and quit.
4. Integrate with existing shell scripts for service control.
5. Implement settings storage and retrieval.
6. Add error handling and logging.

## Important Considerations

- Ensure seamless integration with the existing file renaming functionality.
- Maintain low resource usage, especially when the service is idle.
- Follow macOS Human Interface Guidelines for status bar icons and menus.
- Implement proper error handling and user feedback mechanisms.

## Resources

- macOS Human Interface Guidelines: [https://developer.apple.com/design/human-interface-guidelines/macos/](https://developer.apple.com/design/human-interface-guidelines/macos/)
- NSStatusItem Documentation: [https://developer.apple.com/documentation/appkit/nsstatusitem](https://developer.apple.com/documentation/appkit/nsstatusitem)

By referring to this document and the associated tool-bar-steps-v01.md file, an AI assistant or co-pilot should be able to quickly understand the context of the project and continue development effectively, even if previous context is lost.
