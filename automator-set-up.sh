#!/bin/bash

# Set PATH to include common locations for tools
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# If Homebrew is installed, add its paths
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Enable error handling
set -e

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$HOME/.local/log/automator-set-up.log"
}

# Log script start
log_message "automator-set-up.sh started"

# Log the current PATH
log_message "Current PATH: $PATH"

# Find the DuplicateFileManager.sh script
MANAGER_SCRIPT="$HOME/.local/bin/DuplicateFileManager.sh"

if [ ! -f "$MANAGER_SCRIPT" ]; then
    log_message "Error: DuplicateFileManager.sh not found at $MANAGER_SCRIPT"
    osascript -e 'display notification "DuplicateFileManager.sh not found. Check installation." with title "Error" sound name "Basso"'
    exit 1
fi

# Run the DuplicateFileManager.sh script with the toggle argument
log_message "Running DuplicateFileManager.sh toggle"
"$MANAGER_SCRIPT" toggle

# Check the exit status
if [ $? -eq 0 ]; then
    log_message "DuplicateFileManager.sh executed successfully"
    osascript -e 'display notification "DuplicateWithTimestamp service toggled successfully" with title "Service Toggled"'
else
    log_message "Error: DuplicateFileManager.sh failed to execute"
    osascript -e 'display notification "Failed to toggle DuplicateWithTimestamp service. Check logs for details." with title "Error" sound name "Basso"'
    exit 1
fi

log_message "automator-set-up.sh completed"