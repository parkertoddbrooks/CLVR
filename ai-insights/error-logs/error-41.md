parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status --ignored
On branch dmg-installer
Untracked files:
  (use "git add <file>..." to include in what will be committed)
    _dev_files/automator-app/cleaned-and-signed/
    ai-insights/error-logs/error-36.md
    ai-insights/error-logs/error-37.md
    ai-insights/error-logs/error-38.md
    ai-insights/error-logs/error-39.md
    ai-insights/error-logs/error-40.md

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

nothing added to commit but untracked files present (use "git add" to track)
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % grep "DuplicateWithTimestamp.app" .gitignore
*~_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git check-ignore -v _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git rm --cached _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app
fatal: pathspec '_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app' did not match any files
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status --ignored
On branch dmg-installer
Untracked files:
  (use "git add <file>..." to include in what will be committed)
    _dev_files/automator-app/cleaned-and-signed/
    ai-insights/error-logs/error-36.md
    ai-insights/error-logs/error-37.md
    ai-insights/error-logs/error-38.md
    ai-insights/error-logs/error-39.md
    ai-insights/error-logs/error-40.md

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

nothing added to commit but untracked files present (use "git add" to track)
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ls -l _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app
total 0
drwxr-xr-x  7 parker  staff  224 Jul 25 13:42 Contents
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app
On branch dmg-installer
Untracked files:
  (use "git add <file>..." to include in what will be committed)
    _dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app/

nothing added to commit but untracked files present (use "git add" to track)
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status _dev_files/automator-app/cleaned-and-signed/
On branch dmg-installer
Untracked files:
  (use "git add <file>..." to include in what will be committed)
    _dev_files/automator-app/cleaned-and-signed/

nothing added to commit but untracked files present (use "git add" to track)
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cat .gitignore | grep DuplicateWithTimestamp
sed -i '' 's|*~_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app|_dev_files/automator-app/cleaned-and-signed/DuplicateWithTimestamp.app|g' .gitignore
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % git status --ignored
On branch dmg-installer
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
    modified:   .gitignore

Untracked files:
  (use "git add <file>..." to include in what will be committed)
    _dev_files/automator-app/cleaned-and-signed/
    ai-insights/error-logs/error-36.md
    ai-insights/error-logs/error-37.md
    ai-insights/error-logs/error-38.md
    ai-insights/error-logs/error-39.md
    ai-insights/error-logs/error-40.md

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

no changes added to commit (use "git add" and/or "git commit -a")
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
