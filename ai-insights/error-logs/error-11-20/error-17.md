parker@PxB-MBP-16 Automator % bash -x /Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh/Automator/DuplicateFileManager.sh start
+ mkdir -p /Users/parker/.local/log
+ main start
+ case "$1" in
+ start_launchagent
+ is_launchagent_running
+ launchctl list
+ grep com.user.DuplicateWithTimestamp
+ log_message 'DuplicateWithTimestamp LaunchAgent is already running.'
++ date
+ echo 'Sat Jul 20 07:21:52 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.'
parker@PxB-MBP-16 Automator % 


parker@PxB-MBP-16 Automator % cat ~/.local/log/DuplicateFileManager.log
Sat Jul 20 06:39:02 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 06:39:39 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:19:16 PDT 2024: Loading DuplicateWithTimestamp LaunchAgent...
Sat Jul 20 07:19:16 PDT 2024: DuplicateWithTimestamp LaunchAgent loaded successfully.
Sat Jul 20 07:19:34 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:20:04 PDT 2024: DuplicateWithTimestamp LaunchAgent is running.
Sat Jul 20 07:21:52 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
parker@PxB-MBP-16 Automator % cat ~/.local/log/DuplicateFileManager.log
Sat Jul 20 06:39:02 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 06:39:39 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:19:16 PDT 2024: Loading DuplicateWithTimestamp LaunchAgent...
Sat Jul 20 07:19:16 PDT 2024: DuplicateWithTimestamp LaunchAgent loaded successfully.
Sat Jul 20 07:19:34 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
Sat Jul 20 07:20:04 PDT 2024: DuplicateWithTimestamp LaunchAgent is running.
Sat Jul 20 07:21:52 PDT 2024: DuplicateWithTimestamp LaunchAgent is already running.
parker@PxB-MBP-16 Automator % 
