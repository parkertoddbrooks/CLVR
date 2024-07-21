 # Duplicate File and Update Name with Timestamp - Development Summary (v07)

## Project Overview
The Duplicate File and Update Name with Timestamp is a macOS service designed to automatically rename duplicated files with timestamps. This update focuses on improving the installation process, addressing permission issues, and enhancing the overall reliability of the automated background process.

## Key Features
1. Monitors specified directories (Desktop and Documents, including dev and projects subdirectories) for file duplication events
2. Automatically renames duplicated files with timestamps
3. Handles multiple duplications by appending additional timestamps
4. Works with files ending in " copy" (case insensitive) or files already renamed by this script
5. Runs as a background process using launchd
6. Includes a toggle application for easy enabling/disabling of the service

## Implementation Details

### Shell Script (DuplicateWithTimestamp.sh)
- Located in: ~/.local/bin/DuplicateWithTimestamp.sh
- Dependencies: fswatch (system utility)
- Uses `fswatch` for file system monitoring
- Utilizes bash scripting for file renaming logic
- Monitors the user's Desktop and Documents folders, including dev and projects subdirectories

### LaunchAgent (com.user.DuplicateWithTimestamp.plist)
- Located in: ~/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
- Configured to run the shell script as a background process
- Includes environment variables to ensure correct PATH settings

### Toggle Application (ToggleDuplicateWithTimestamp.app)
- AppleScript-based application for easy enabling/disabling of the service
- Located in: /Applications/ToggleDuplicateWithTimestamp.app

## Recent Updates (v07)
1. Created a comprehensive installation script (install.sh)
2. Improved error handling and logging in the main script
3. Added checks for existing files and directories in the installation process
4. Updated LaunchAgent plist file to include necessary environment variables
5. Enhanced the toggle application for better user interaction
6. Addressed permission issues related to accessing dev and projects folders

## Current Challenges
1. Ensuring consistent performance across different macOS security settings
2. Handling potential permission issues in deeply nested directory structures
3. Optimizing performance for large numbers of files or frequent duplication events

## Development Process
1. Iterative improvements based on user feedback and testing
2. Enhanced installation process with better error handling and user feedback
3. Refined LaunchAgent configuration for improved reliability
4. Extensive testing across various macOS versions and configurations

## Future Steps
1. Implement more robust error reporting and logging mechanisms
2. Consider adding a configuration file for user-customizable settings
3. Explore options for handling edge cases (e.g., network drives, cloud storage sync folders)
4. Develop a graphical user interface for more advanced configuration options
5. Implement unit and integration tests for improved code reliability

## Installation and Usage
1. Run the install.sh script to set up all components
2. Use the ToggleDuplicateWithTimestamp.app to enable or disable the service
3. The service will automatically run in the background when enabled
4. Duplicated files in the monitored directories will be renamed with timestamps

## Troubleshooting
1. Check ~/.local/log/duplicatewithtimestamp.log for error messages
2. Ensure fswatch is correctly installed and accessible in the system PATH
3. Verify that the LaunchAgent has the correct permissions and is loaded
4. Check System Preferences > Security & Privacy > Privacy for necessary permissions

## Conclusion
The Duplicate File and Update Name with Timestamp tool has seen significant improvements in its installation process and overall reliability. With enhanced error handling, better permissions management, and a more robust LaunchAgent configuration, the service is now more capable of handling various user environments and macOS security settings. Future development will focus on further improving user customization options and handling more complex file system scenarios.
