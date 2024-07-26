Last login: Sun Jul 21 10:35:05 on ttys000
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ./install.sh                        
DuplicateWithTimestamp.sh has been copied and made executable.
DuplicateFileManager.sh has been copied and made executable.
Installation complete. Scripts have been copied to ~/.local/bin/ and made executable.
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ~/.local/bin/DuplicateFileManager.sh status
+ SCRIPT_DIR=/Users/parker/.local/bin
+ mkdir -p /Users/parker/.local/log
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ main status
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ case "$1" in
+ check_status
+ '[' -f /Users/parker/.local/DuplicateWithTimestamp.pid ']'
+ log_message 'DuplicateWithTimestamp is not running.'
++ date
+ echo 'Sun Jul 21 11:07:39 PDT 2024: DuplicateWithTimestamp is not running.'
+ log_message 'DuplicateFileManager.sh completed'
++ date
+ echo 'Sun Jul 21 11:07:39 PDT 2024: DuplicateFileManager.sh completed'
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ~/.local/bin/DuplicateFileManager.sh stop 
+ SCRIPT_DIR=/Users/parker/.local/bin
+ mkdir -p /Users/parker/.local/log
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ main stop
+ is_running_in_automator
+ '[' '' '!=' '' ']'
+ case "$1" in
+ stop_script
+ '[' -f /Users/parker/.local/DuplicateWithTimestamp.pid ']'
+ log_message 'DuplicateWithTimestamp is not running.'
++ date
+ echo 'Sun Jul 21 11:08:01 PDT 2024: DuplicateWithTimestamp is not running.'
+ log_message 'DuplicateFileManager.sh completed'
++ date
+ echo 'Sun Jul 21 11:08:01 PDT 2024: DuplicateFileManager.sh completed'
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ps aux | grep DuplicateWithTimestamp.sh 
parker           88847   0.2  0.0 34252368    756 s003  R+   11:08AM   0:00.00 grep DuplicateWithTimestamp.sh
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh %  kill 88847
kill: kill 88847 failed: no such process
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 

