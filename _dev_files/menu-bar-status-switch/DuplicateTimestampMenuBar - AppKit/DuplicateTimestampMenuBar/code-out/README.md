# DuplicateTimestampMenuBar

A macOS menu bar application that automatically renames duplicated files in your Desktop and Documents folders by adding a timestamp.

## Features

- Watches Desktop and Documents folders for file duplications
- Automatically renames duplicated files with a timestamp
- Menu bar interface for easy access and control
- Debug mode for troubleshooting

## Requirements

- macOS 10.15 or later
- Xcode 12.0 or later (for development)

## Installation

1. Clone the repository or download the source code.
2. Open the project in Xcode.
3. Build and run the application.

## Setup

1. Ensure the entitlements file is properly linked:
   - Open the Xcode project for DuplicateTimestampMenuBar.
   - Select the project in the Project Navigator.
   - Choose the DuplicateTimestampMenuBar target.
   - Go to the "Signing & Capabilities" tab.
   - Ensure that the "DuplicateTimestampMenuBar.entitlements" file is selected for the "Entitlements File" setting.

2. Grant necessary permissions:
   - When you first run the app, it will request permission to access your Desktop and Documents folders.
   - Grant these permissions to allow the app to function correctly.

## Usage

1. Launch the application.
2. Click on the menu bar icon to access the app's menu.
3. Toggle the "Duplicate + Timestamp" switch to enable or disable the file watching feature.
4. Use the "Toggle Debug Mode" option for troubleshooting if needed.

## Development

- The `AppDelegate.swift` file contains the main logic for file watching and renaming.
- Security-scoped bookmarks are used to maintain folder access permissions.
- Unit tests are available in the `DuplicateTimestampMenuBarTests.swift` file.

## Known Issues

- If you encounter any issues with folder permissions, try toggling the file watching feature off and on again.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
