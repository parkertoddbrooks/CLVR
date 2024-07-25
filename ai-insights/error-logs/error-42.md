parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cat .gitignore | grep DuplicateWithTimestamp
sed -i '' 's|*~_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app|_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app|g' .gitignore
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git rm -r --cached .
rm '.gitignore'
rm 'LICENSE'
rm 'README-dev-resource-updating-and-creating-DMG.md'
rm 'README.md'
rm '_dev_files/automator-app/clean_and_sign_rsync.sh'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Info.plist'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/MacOS/Automator Application Stub'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/ApplicationStub.icns'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/Assets.car'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/DuplicateFileManager.sh'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/DuplicateWithTimestamp.sh'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/Resources/InfoPlist.loctable'
rm '_dev_files/automator-app/original-unsigned/DuplicateWithTimestamp.app/Contents/document.wflow'
rm '_dev_files/code-for-automator-app/automator-workflow.sh'
rm '_dev_files/dmg-build-parts/DMG-Canvas/DuplicateWithTimestamp_Installer.dmgcanvas/Contents/English.rtf'
rm '_dev_files/dmg-build-parts/DMG-Canvas/DuplicateWithTimestamp_Installer.dmgcanvas/Contents/volumeIcon.png'
rm '_dev_files/dmg-build-parts/DMG-Canvas/DuplicateWithTimestamp_Installer.dmgcanvas/Disk Image'
rm '_dev_files/dmg-build-parts/DMG-Canvas/DuplicateWithTimestamp_Installer.dmgcanvas/QuickLook/Preview.jpg'
rm '_dev_files/dmg-build-parts/DMG-Canvas/images/ApplicationStub.icns'
rm '_dev_files/dmg-build-parts/DMG-Canvas/images/ApplicationStub.png'
rm '_dev_files/dmg-build-parts/DMG-Canvas/images/Folder-Apps-icon.png'
rm '_marketing_files/DESCRIPTION.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-01.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-02.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-03.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-04.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-05.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-06.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-07.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-08.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-09.md'
rm 'ai-insights/cli-dump/cli-dump-01-10/cli-dump-10.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-11.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-12.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-13.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-14.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-15.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-16.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-17-5.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-17.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-18.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-19.md'
rm 'ai-insights/cli-dump/cli-dump-11-20/cli-dump-20.md'
rm 'ai-insights/cli-dump/cli-dump-21.md'
rm 'ai-insights/cli-dump/cli-dump-22.md'
rm 'ai-insights/cli-dump/cli-dump-23.md'
rm 'ai-insights/cli-dump/cli-dump-24.md'
rm 'ai-insights/cli-dump/cli-dump-25.md'
rm 'ai-insights/cli-dump/cli-dump-26.md'
rm 'ai-insights/cli-dump/cli-dump-27.md'
rm 'ai-insights/cli-dump/cli-dump-28.md'
rm 'ai-insights/dev-summaries/app-summary-v01.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v01.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v02.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v03.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v04.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v05.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v06.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v07.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v08.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v09.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v10.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v11.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v12.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v13-5.md.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v13.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v14.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v15.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v16.md'
rm 'ai-insights/dev-summaries/project_progress_summary-DuplicateFileUpdater-v17.md'
rm 'ai-insights/error-logs/error-1-10/error-01.md'
rm 'ai-insights/error-logs/error-1-10/error-02.md'
rm 'ai-insights/error-logs/error-1-10/error-03.md'
rm 'ai-insights/error-logs/error-1-10/error-04.md'
rm 'ai-insights/error-logs/error-1-10/error-05.md'
rm 'ai-insights/error-logs/error-1-10/error-06.md'
rm 'ai-insights/error-logs/error-1-10/error-07.png'
rm 'ai-insights/error-logs/error-1-10/error-08.md'
rm 'ai-insights/error-logs/error-1-10/error-09.md'
rm 'ai-insights/error-logs/error-1-10/error-10.md'
rm 'ai-insights/error-logs/error-11-20/error-11.png'
rm 'ai-insights/error-logs/error-11-20/error-12.png'
rm 'ai-insights/error-logs/error-11-20/error-15.md'
rm 'ai-insights/error-logs/error-11-20/error-16 copy 2.md'
rm 'ai-insights/error-logs/error-11-20/error-16.md'
rm 'ai-insights/error-logs/error-11-20/error-17.md'
rm 'ai-insights/error-logs/error-11-20/error-18.png'
rm 'ai-insights/error-logs/error-11-20/error-20.md'
rm 'ai-insights/error-logs/error-21-30/error-21.md'
rm 'ai-insights/error-logs/error-21-30/error-22.md'
rm 'ai-insights/error-logs/error-21-30/error-23.md'
rm 'ai-insights/error-logs/error-21-30/error-24.md'
rm 'ai-insights/error-logs/error-21-30/error-25.md'
rm 'ai-insights/error-logs/error-21-30/error-26.md'
rm 'ai-insights/error-logs/error-21-30/error-27.md'
rm 'ai-insights/error-logs/error-21-30/error-28.md'
rm 'ai-insights/error-logs/error-21-30/error-29.md'
rm 'ai-insights/error-logs/error-21-30/error-30.md'
rm 'ai-insights/error-logs/error-31.md'
rm 'ai-insights/error-logs/error-32.md'
rm 'ai-insights/error-logs/error-33.md'
rm 'ai-insights/error-logs/error-34.png'
rm 'ai-insights/error-logs/error-35.png'
rm 'ai-insights/promts/create_example_project_context_prompt.md'
rm 'ai-insights/promts/generic_project_context_prompt.md'
rm 'ai-insights/promts/project_context_prompt-v01.md'
rm 'ai-insights/promts/project_context_prompt-v02.md'
rm 'ai-insights/promts/project_context_prompt-v03.md'
rm 'ai-insights/steps/control-bar-icon-and-signing-todo.md'
rm 'ai-insights/steps/dmg-steps-v01.md'
rm 'ai-insights/steps/dmg-steps-v02.md'
rm 'ai-insights/steps/dmg-steps-v03.md'
rm 'ai-insights/test-file.md'
rm 'app-binary/DuplicateWithTimestamp_Installer.dmg'
rm 'app-cli/DuplicateFileManager.sh'
rm 'app-cli/DuplicateWithTimestamp.sh'
rm 'app-cli/setup.sh'
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git add .
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status --ignored
On branch dmg-installer
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
    modified:   .gitignore
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Info.plist
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/MacOS/Automator Application Stub
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/ApplicationStub.icns
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/Assets.car
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateFileManager.sh
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/DuplicateWithTimestamp.sh
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/Resources/InfoPlist.loctable
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/_CodeSignature/CodeResources
    new file:   _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/Contents/document.wflow
    new file:   ai-insights/error-logs/error-36.md
    new file:   ai-insights/error-logs/error-37.md
    new file:   ai-insights/error-logs/error-38.md
    new file:   ai-insights/error-logs/error-39.md
    new file:   ai-insights/error-logs/error-40.md
    new file:   ai-insights/error-logs/error-41.md

Ignored files:
  (use "git add -f <file>..." to include in what will be committed)
    .DS_Store
    _dev_files/.DS_Store
    _dev_files/automator-app/.DS_Store
    _dev_files/automator-app/cleaned-and-signed/.DS_Store
    _dev_files/automator-app/original-unsigned/.DS_Store
    _dev_files/dmg-build-parts/.DS_Store
    _dev_files/dmg-build-parts/DMG-Canvas/.DS_Store
    ai-insights/.DS_Store
    ai-insights/error-logs/.DS_Store

parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 

