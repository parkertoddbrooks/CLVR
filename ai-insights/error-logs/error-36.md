parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git checkout main
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Info.plist': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/MacOS/Automator Application Stub': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/ApplicationStub.icns': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/Assets.car': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateFileManager.sh': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateWithTimestamp.sh': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/InfoPlist.loctable': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/_CodeSignature/CodeResources': Permission denied
warning: unable to unlink '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/document.wflow': Permission denied
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git pull origin main
From github.com:parkertoddbrooks/duplicate-file-and-update-name-with-timestamp-sh
 * branch            main       -> FETCH_HEAD
Already up to date.
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git merge dmg-installer
Updating 20b2d8e..0d203d7
error: The following untracked working tree files would be overwritten by merge:
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
Please move or remove them before you merge.
Aborting

