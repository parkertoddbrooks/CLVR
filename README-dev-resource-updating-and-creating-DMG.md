# Updating DuplicateWithTimestamp.app and Creating the DMG Installer

This document outlines the process for updating. signing and notarizing the Automator app, and then creating a signed and notarized DMG for binary distribution enabling simple user installation.

## Directory Structure

```
duplicate-file-and-update-name-with-timestamp-sh/
├── _dev_files/
│   ├── automator-app/
│   │   ├── cleaned-and-signed
|   |   |── original-unsigned
|   |   |   └── DuplicateWithTimestamp.app
│   │   └── clean_and_sign_rsync.sh
│   ├── code-for-automator-app/
│   │   └── automator-workflow.sh
│   └── dmg-build-parts/
│       └── DMG-Canvas/
│           └── DuplicateWithTimestamp_Installer.dmgcanvas
├── app-binary/
│   └── DuplicateWithTimestamp_Installer.dmg
├── app-cli/
│   ├── DuplicateWithTimestamp.sh
│   ├── DuplicateFileManager.sh
│   └── setup.sh
├── LICENSE
├── README.md
└── README-dev-resource-updating-and-creating-DMG.md
```

## Updating the Automator App

1. Open the existing DuplicateWithTimestamp.app from `_dev_files/automator-app/original-unsigned` in Automator.

2. Copy the contents of `_dev_files/code-for-automator-app/automator-workflow.sh` into the "Run Shell Script" action in the Automator app if updated/

3. Save the Automator app.

4. Navigate to the Resources folder of the app bundle:
   - Right-click on DuplicateWithTimestamp.app and select "Show Package Contents"
   - Go to Contents/Resources/

5. Copy the most up-to-date versions of the following files into the Resources folder at `app-cli`. Every time you save a new version of automator-workflow.sh Automator will clear the any previous files in `Contents/Resources/`.
   - DuplicateWithTimestamp.sh
   - DuplicateFileManager.sh

## Cleaning and Signing the App

Before signing, you will need your own Developer ID Application and will need to replace, "Developer ID Application: Parker Brooks (6RLN3QRWBQ)". You can create it at: https://developer.apple.com/account/resources/certificates/list

1. Open Terminal and navigate to the `_dev_files/automator-app/` directory.

2. Make the cleaning and signing script executable:
   ```
   chmod +x clean_and_sign_rsync.sh
   ```

3. Run the cleaning and signing script:
   ```
   sudo ./clean_and_sign_rsync.sh
   ```
   
   This script will create a cleaned and signed version of DuplicateWithTimestamp.app in the `cleaned-and-signed/` directory.

## Creating the DMG for Distribution

1. Open DMG Canvas and load the project file:
   `_dev_files/dmg-build-parts/DMG-Canvas/DuplicateWithTimestamp_Installer.dmgcanvas`

2. Selet your disk image, and for Gatekeeper, select your "Developer ID Application" to sign and notarize.

3. In DMG Canvas, go to the "Build" menu and select "Build" (or use the keyboard shortcut).

4. Choose the destination for the built DMG file (typically the `app-binary/` directory).

5. DMG Canvas will create and sign the DMG file.

6. Verify the newly created DMG by opening it and testing the app installation.

## Testing

1. Copy the DuplicateWithTimestamp.app from the newly created DMG to /Applications/.

2. Run the app from /Applications/ to ensure it works as expected.

3. Check the log files (usually in $HOME/) for any errors or issues.
