#!/bin/bash

# Enable debug mode
set -x

# Get the directory of the script
SCRIPT_DIR="$HOME/.local/bin"

# Create necessary directories
mkdir -p "$HOME/.local/log"

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$HOME/.local/log/DuplicateFileManager.log"
}

# Function to determine if script is running in Automator
is_running_in_automator() {
    [ "$AUTOMATOR_PID" != "" ]
}

# Redirect all output to log file when running in Automator
if is_running_in_automator; then
    exec > "$HOME/.local/log/DuplicateFileManager_automator.log" 2>&1
fi

# Function to toggle the script
toggle_script() {
    if [ -f "$HOME/.local/DuplicateWithTimestamp.pid" ]; then
        stop_script
    else
        start_script
    fi
}

# Function to start the script
start_script() {
    if [ -f "$HOME/.local/DuplicateWithTimestamp.pid" ]; then
        log_message "DuplicateWithTimestamp is already running."
    else
        if [ ! -f "$HOME/.local/bin/DuplicateWithTimestamp.sh" ]; then
            log_message "DuplicateWithTimestamp.sh not found. Please ensure it's installed correctly."
            return 1
        fi

        log_message "Starting DuplicateWithTimestamp..."
        log_message "Current PATH: $PATH"
        log_message "fswatch location: $(which fswatch)"
        log_message "Command: nohup \"$HOME/.local/bin/DuplicateWithTimestamp.sh\" > /dev/null 2>&1 & echo $!"
        nohup "$HOME/.local/bin/DuplicateWithTimestamp.sh" > /dev/null 2>&1 & echo $! > "$HOME/.local/DuplicateWithTimestamp.pid"
        PID=$(cat "$HOME/.local/DuplicateWithTimestamp.pid")
        sleep 1
        if ps -p $PID > /dev/null; then
            log_message "DuplicateWithTimestamp started successfully with PID $PID"
            osascript -e "display notification \"DuplicateWithTimestamp started with PID $PID\" with title \"DuplicateFileManager\""
        else
            log_message "Error: Failed to start DuplicateWithTimestamp"
            osascript -e "display notification \"Failed to start DuplicateWithTimestamp\" with title \"Error\" sound name \"Basso\""
            rm "$HOME/.local/DuplicateWithTimestamp.pid"
            return 1
        fi
    fi
}

# Function to stop the script
stop_script() {
    log_message "Stopping DuplicateWithTimestamp..."
    
    # Kill all fswatch processes related to our script
    pkill -f "fswatch.*Desktop.*Documents"
    
    # Kill the main script if it's running
    if [ -f "$HOME/.local/DuplicateWithTimestamp.pid" ]; then
        PID=$(cat "$HOME/.local/DuplicateWithTimestamp.pid")
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
        fi
        rm "$HOME/.local/DuplicateWithTimestamp.pid"
    fi
    
    # Double-check if any related processes are still running
    if pgrep -f "DuplicateWithTimestamp.sh" > /dev/null || pgrep -f "fswatch.*Desktop.*Documents" > /dev/null; then
        log_message "Force stopping remaining processes..."
        pkill -9 -f "DuplicateWithTimestamp.sh"
        pkill -9 -f "fswatch.*Desktop.*Documents"
    fi
    
    log_message "DuplicateWithTimestamp stopped."
    osascript -e "display notification \"DuplicateWithTimestamp stopped\" with title \"DuplicateFileManager\""
}

check_if_running() {
    if pgrep -f "DuplicateWithTimestamp.sh" > /dev/null || pgrep -f "fswatch.*Desktop.*Documents" > /dev/null; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Function to check the status of the script
check_status() {
    if check_if_running; then
        log_message "DuplicateWithTimestamp is running."
    else
        log_message "DuplicateWithTimestamp is not running."
    fi
}

# Main function
main() {
    if is_running_in_automator; then
        toggle_script
    else
        case "$1" in
            start)
                start_script
                ;;
            stop)
                stop_script
                ;;
            status)
                check_status
                ;;
            toggle)
                toggle_script
                ;;
            *)
                echo "Usage: $0 {start|stop|status|toggle}"
                exit 1
                ;;
        esac
    fi
}

# Call main function with command-line argument if not running in Automator
if ! is_running_in_automator; then
    main "$1"
else
    main
fi

log_message "DuplicateFileManager.sh completed"
