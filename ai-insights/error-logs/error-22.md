Last login: Sat Jul 20 09:37:18 on ttys003
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % which fswatch  
/usr/local/bin/fswatch
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh %  
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ls -l ~/.local/bin/DuplicateWithTimestamp.sh
-rwxr-xr-x  1 parker  staff  3862 Jul 20 10:32 /Users/parker/.local/bin/DuplicateWithTimestamp.sh
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ~/.local/bin/DuplicateWithTimestamp.sh
Successfully renamed: /Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh/README copy.md to README-copy-2024-07-21-075521.md
^C[ERROR] fswatch command failed
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cat ~/.local/log/DuplicateWithTimestamp.log
+ check_fswatch
+ command -v fswatch
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721430582
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
find: /Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh: Operation not permitted
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721433518
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
find: /Users/parker/Documents/dev/claude-engineer: Operation not permitted
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721434749
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
Sat Jul 20 07:09:14 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 07:09:14 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 07:09:14 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 07:09:14 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 07:09:14 PDT 2024: Created/updated log file at /Users/parker/.local/log/duplicatewithtimestamp.log
Sat Jul 20 07:17:24 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 07:17:24 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 07:17:24 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 07:17:24 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 07:17:24 PDT 2024: Created/updated log file at /Users/parker/.local/log/duplicatewithtimestamp.log
Sat Jul 20 09:43:10 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 09:43:10 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 09:43:10 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 09:43:10 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 10:09:21 PDT 2024: Created directory /Applications/Duplicate-File-With-Timestamp
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ps aux | grep DuplicateWithTimestamp
parker           62519   0.0  0.0 34252368    784 s003  S+    7:57AM   0:00.00 grep DuplicateWithTimestamp
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ps aux | grep DuplicateWithTimestamp
parker           62524   0.0  0.0 34252368    788 s003  S+    7:57AM   0:00.00 grep DuplicateWithTimestamp
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cat ~/.local/log/DuplicateWithTimestamp.log
+ check_fswatch
+ command -v fswatch
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721430582
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
find: /Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh: Operation not permitted
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721433518
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
find: /Users/parker/Documents/dev/claude-engineer: Operation not permitted
+ check_fswatch
+ command -v fswatch
+ DEBUG=false
+ getopts :d opt
+ WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")
++ date +%s
+ START_TIME=1721434749
+ export -f rename_file
+ export START_TIME
+ export DEBUG
+ export -f debug_log
+ export -f error_log
+ main
+ fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
+ xargs -0 -n 1 -I '{}' bash -c 'rename_file "$@"' _ '{}'
Sat Jul 20 07:09:14 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 07:09:14 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 07:09:14 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 07:09:14 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 07:09:14 PDT 2024: Created/updated log file at /Users/parker/.local/log/duplicatewithtimestamp.log
Sat Jul 20 07:17:24 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 07:17:24 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 07:17:24 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 07:17:24 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 07:17:24 PDT 2024: Created/updated log file at /Users/parker/.local/log/duplicatewithtimestamp.log
Sat Jul 20 09:43:10 PDT 2024: Overwrote existing com.user.DuplicateWithTimestamp.plist in /Users/parker/Library/LaunchAgents
Sat Jul 20 09:43:10 PDT 2024: Set permissions for /Users/parker/Library/LaunchAgents/com.user.DuplicateWithTimestamp.plist
Sat Jul 20 09:43:10 PDT 2024: Overwrote existing DuplicateWithTimestamp.sh in /Users/parker/.local/bin
Sat Jul 20 09:43:10 PDT 2024: Set permissions for /Users/parker/.local/bin/DuplicateWithTimestamp.sh
Sat Jul 20 10:09:21 PDT 2024: Created directory /Applications/Duplicate-File-With-Timestamp
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % cat ~/.local/log/DuplicateFileManager.log
Sat Jul 20 06:39:02 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 06:39:39 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:19:16 PDT 2024: Loading DuplicateWithTimestamp LaunchAgent...
Sat Jul 20 07:19:16 PDT 2024: DuplicateWithTimestamp LaunchAgent loaded successfully.
Sat Jul 20 07:19:34 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:20:04 PDT 2024: DuplicateWithTimestamp LaunchAgent is running.
Sat Jul 20 07:21:52 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 10:32:43 PDT 2024: Starting DuplicateWithTimestamp...
Sat Jul 20 10:32:43 PDT 2024: DuplicateWithTimestamp started with PID 93761
Sat Jul 20 10:32:57 PDT 2024: Stopping DuplicateWithTimestamp (PID: 93761)...
Sat Jul 20 10:32:57 PDT 2024: DuplicateWithTimestamp stopped.
Sat Jul 20 10:33:00 PDT 2024: Starting DuplicateWithTimestamp...
Sat Jul 20 10:33:00 PDT 2024: DuplicateWithTimestamp started with PID 93814
Sat Jul 20 10:33:02 PDT 2024: Stopping DuplicateWithTimestamp (PID: 93814)...
Sat Jul 20 10:33:02 PDT 2024: DuplicateWithTimestamp stopped.
Sat Jul 20 10:33:04 PDT 2024: Starting DuplicateWithTimestamp...
Sat Jul 20 10:33:04 PDT 2024: DuplicateWithTimestamp started with PID 93845
Sat Jul 20 10:33:11 PDT 2024: Stopping DuplicateWithTimestamp (PID: 93845)...
Sat Jul 20 10:33:11 PDT 2024: DuplicateWithTimestamp stopped.
Sun Jul 21 07:36:57 PDT 2024: Starting DuplicateWithTimestamp...
Sun Jul 21 07:36:57 PDT 2024: DuplicateWithTimestamp started with PID 59779
Sun Jul 21 07:37:08 PDT 2024: Stopping DuplicateWithTimestamp (PID: 59779)...
Sun Jul 21 07:37:08 PDT 2024: DuplicateWithTimestamp stopped.
Sun Jul 21 07:56:52 PDT 2024: Starting DuplicateWithTimestamp...
Sun Jul 21 07:56:52 PDT 2024: DuplicateWithTimestamp started with PID 62450
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 

