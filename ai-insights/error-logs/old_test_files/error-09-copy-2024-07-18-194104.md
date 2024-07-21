Last login: Thu Jul 18 18:40:43 on ttys002
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % sudo cp rename_duplicate.sh /usr/local/bin/
Password:
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % sudo chmod +x /usr/local/bin/rename_duplicate.sh 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cp com.user.fswatchrename.plist ~/Library/LaunchAgents/
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % launchctl load ~/Library/LaunchAgents/com.user.fswatchrename.plist
Load failed: 5: Input/output error
Try running `launchctl bootstrap` as root for richer errors.
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 






