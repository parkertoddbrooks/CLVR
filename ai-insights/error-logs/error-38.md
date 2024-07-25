parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git fetch origin
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git reset --hard origin/main
HEAD is now at 20b2d8e Update README.md
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git checkout dmg-installer
error: The following untracked working tree files would be overwritten by checkout:
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Info.plist
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/MacOS/Automator Application Stub
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/ApplicationStub.icns
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/Assets.car
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateFileManager.sh
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateWithTimestamp.sh
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/InfoPlist.loctable
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/_CodeSignature/CodeResources
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/document.wflow
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Info.plist
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/MacOS/Automator Application Stub
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/ApplicationStub.icns
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/Assets.car
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/DuplicateFileManager.sh
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/DuplicateWithTimestamp.sh
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/InfoPlist.loctable
    _dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/document.wflow
Please move or remove them before you switch branches.
Aborting
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
