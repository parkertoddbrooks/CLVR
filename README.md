# CLVR (klōvər)

CLVR (klōvər) - v2.0.0

A macOS utility that automatically appends timestamps to duplicated file names.

### How to Use:
1. Select any file and press Command-D to duplicate it.
2. The duplicated file, initially named filename `copy.file-extension`, will be automatically renamed to `filename--YYYY-MM-DD--HH-MM-SS.file-extension`.

### Key features:
- Low impact background operations
- Visual feedback via animated menu bar icon
- Two timestamp formats
- On/Off toggle switch, and flexible app visibility (Dock, Menu Bar, or both)
- Preserves file extension, and works on hidden files
- Compatible with open at login preferences

### Privacy Considerations:
- Only accesses and modifies files in user-selected folders
- File monitoring is limited to detecting changes for renaming purposes only
- No data is transmitted outside of the user's system
- More info here: [security-brief.md](security-brief.md)

## Quick Start
1. Download the latest macOS version of CLVR from [GitHub Releases](https://github.com/parkertoddbrooks/CLVR/releases)

2. App is also available on the [Mac App Store](APP STORE URL). (Coming soon)

## AI-Assisted Development Insights

The project was developed with Claude Sonnet 3.5, ChatGPT 4o, Claude Engineer CLI, Cursor and Xcode. The `/ai_insight/` directory contains valuable information about this AI-assisted development approach:

### cli-dump
Complete transcripts of Claude Engineering CLI sessions.

### dev-summaries
Comprehensive project progress updates that allow any AI or developer to quickly understand the current state of the project. This serves as a continuity mechanism to preserve context beyond various model and system limitations, including token limits, context windows, session boundaries, rate limits, stateless API interactions, parsing complexities, and cross-model compatibility issues. 

### error-logs
CLI outputs for each encountered bug. These are submitted to Claude via Markdown files rather than direct paste to prevent formatting issues caused by multiple carriage returns. This method helps maintain Claude Engineer's stability when processing large blocks of text.

### PRDs
Product requirement documents generated by both OpenAI and Anthropic, outlining the specifications for this project or PRDs we for features we created as we developed the software.

### prompts
Prompts designed to efficiently bring Claude Engineering CLI back up to speed after any connection or context loss, ensuring continuity in the development process.

### steps
A continuously updated file containing Claude's recommendations for next steps in the project, providing a clear roadmap for development.

## Version History
- v1.0.0 (shell scripts and Automator app)
  - FKA 'Duplicate File and Update Name with Timestamp (App & Shell Script)'
  - Initial release
  - Basic functionality for renaming duplicated files
  - Command-line interface and Automator app support
  
  
- v1.1.0 (shell scripts and Automator app)
  - FKA 'Duplicate File and Update Name with Timestamp (App & Shell Script)'
  - Created a signed and notarized DMG and App for distrubtion and installation
  - Created automatic installation process for all dependencies 
  - Refined file path handling for better cross-system compatibility
  - Enhanced error handling and debugging capabilities
  - Added comprehensive logging for both Automator app and CLI versions
  - Improved documentation, including separate guides for app and CLI usage
  - Improved uninstallation process for cleaner removal
  - Added version history tracking
  - Created a build insights and developer guide
  
  The archive of this version is here: https://github.com/parkertoddbrooks/CLVR/tree/main--archive-2024-09-12

- v2.0.0 (Swift)
  - Re-wrote the codebase in Swift
  - Visual feedback of operation via animated menu bar icon
  - Two selectable timestamp formats
  - Menu bar icon to toggle CLVR on and off
  - Flexible app visibility (Dock, Menu Bar, or both)
  - Preserves file extension
  - Hidden file compatibility
  - Compatible with open at login preferences
  - Added privacy policy
  - Updated Licensing to include app names, imagery, and compiled binaries
  - Added app store release
  - Renamed app and respoitory to CLVR
 
## Support
Please open a ticket on at: https://github.com/parkertoddbrooks/CLVR/issues

## License
This project's source code and project files are licensed under the MIT License. However, the app names, imagery, and compiled binaries are copyrighted. Please see the [LICENSE](LICENSE) file for more details.
