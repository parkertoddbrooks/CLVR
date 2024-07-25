parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ~/.local/bin/DuplicateFileManager.sh start 
+ SCRIPT_DIR=/Users/parker/.local/bin
+ mkdir -p /Users/parker/.local/log
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ main start
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ case "$1" in
+ start_script
+ '[' -f /Users/parker/.local/DuplicateWithTimestamp.pid ']'
+ log_message 'DuplicateWithTimestamp is already running.'
++ date
+ echo 'Sun Jul 21 08:31:37 PDT 2024: DuplicateWithTimestamp is already running.'
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ps aux | grep DuplicateWithTimestamp       
parker           67566   0.0  0.0 34252368    788 s001  S+    8:31AM   0:00.00 grep DuplicateWithTimestamp
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % /

