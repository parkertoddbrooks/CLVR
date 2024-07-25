parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % ps aux | grep -E 'Duplicate|fswatch'
parker           89420   0.9  0.0 34252368    784 s003  S+   11:11AM   0:00.00 grep -E Duplicate|fswatch
parker           88295   0.0  0.0 34138516   1856   ??  S    11:06AM   0:00.02 fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
parker           88180   0.0  0.0 34145684   1816   ??  S    11:06AM   0:00.02 fswatch -0 --event Created /Users/parker/Desktop /Users/parker/Documents
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % kill 89420
kill: kill 89420 failed: no such process
parker@PxB-MBP-16 duplicate-file-and-update-name-with-timestamp-sh % 
