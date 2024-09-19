# Todo List for DMG + Startup Setup Approach

1. Modify DuplicateWithTimestamp.app (Automator app):
   - [ ] Update startup_check.sh to perform setup routine on every startup
   - [ ] Implement startup routine:
     - [ ] Check for ~/.local/bin, create if it doesn't exist
     - [ ] Copy DuplicateWithTimestamp.sh and DuplicateFileManager.sh to ~/.local/bin/
     - [ ] Make the scripts executable (chmod +x)
     - [ ] Update PATH in .bash_profile and .zshrc if necessary
   - [ ] Ensure the app can run the setup with user permissions (no sudo required)
   - [ ] Implement comprehensive logging for debugging

2. Create DMG building script:
   - [ ] Write a shell script (create_dmg.sh) to automate DMG creation
   - [ ] Include steps to:
     - [ ] Create a temporary directory for DMG contents
     - [ ] Copy DuplicateWithTimestamp.app to the temporary directory
     - [ ] Create a symbolic link to /Applications in the temporary directory
     - [ ] Set appropriate icon for the app (if not already done)
     - [ ] Create a background image with installation instructions
     - [ ] Use hdiutil to create the DMG from the temporary directory
     - [ ] Clean up temporary files

3. Update project documentation:
   - [ ] Revise README.md to reflect new installation method
   - [ ] Update INSTALL.md with detailed installation instructions
   - [ ] Update any other relevant documentation files
   - [ ] Create or update a CHANGELOG.md to track versions and updates

4. Testing:
   - [ ] Test DMG creation process
   - [ ] Verify DMG opens correctly and displays installation instructions
   - [ ] Test drag-and-drop installation to Applications folder
   - [ ] Test startup setup process:
     - [ ] Verify scripts are correctly installed to ~/.local/bin/
     - [ ] Confirm PATH is updated if necessary
     - [ ] Ensure setup process runs correctly on each app launch
   - [ ] Test functionality of installed app and scripts
   - [ ] Perform tests on different macOS versions and clean systems

5. Cleanup and organization:
   - [ ] Remove or archive old installer-related files
   - [ ] Organize project structure to reflect new approach
   - [ ] Ensure all necessary files are included in the app bundle

6. Optional enhancements:
   - [ ] Implement a cleanup routine in the app to remove scripts if the app is deleted
   - [ ] Add a "Check for Updates" feature in the app

7. Prepare for distribution:
   - [ ] Decide on a versioning scheme for the DMG
   - [ ] Consider code signing the app for improved security (requires Apple Developer account)
   - [ ] Investigate notarization process for macOS Catalina and later

8. Final review:
   - [ ] Conduct a full review of the new installation process
   - [ ] Update project status and development summary documents
   - [ ] Perform a security audit of the app and its scripts

Remember to test thoroughly at each step, especially on clean macOS systems, to ensure everything works as expected for end-users. Pay special attention to permissions and path issues that may arise from the new setup process.