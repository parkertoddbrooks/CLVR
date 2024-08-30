#!/bin/bash

# Enable error handling
set -e

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$HOME/.local/log/DuplicateWithTimestamp.log"
}

# Log script start and environment
log_message "DuplicateWithTimestamp.sh started. Current environment:"
log_message "$(env | sort)"

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    log_message "Error: fswatch is not installed. Please install it and try again."
    exit 1
fi

# Directories to monitor (Desktop and Documents folders in user's home directory)
WATCH_DIRS=("$HOME/Desktop" "$HOME/Documents")

# Function to rename duplicated files
rename_file() {
    local file="$1"
    log_message "Detected new file: $file"
    
    local dir=$(dirname "$file")
    local filename=$(basename "$file")
    local extension="${filename##*.}"
    local name="${filename%.*}"
    
    if [[ $name =~ .[Cc][Oo][Pp][Yy]$ ]] || [[ $name =~ -copy-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}(--[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6})*$ ]]; then
        local timestamp=$(date +%Y-%m-%d-%H%M%S)
        local new_name
        
        if [[ $name =~ .[Cc][Oo][Pp][Yy]$ ]]; then
            new_name="${name% [Cc][Oo][Pp][Yy]}-copy-${timestamp}.${extension}"
        else
            new_name="${name}--${timestamp}.${extension}"
        fi
        
        log_message "Renaming $file to $new_name"
        mv "$file" "$dir/$new_name"
        if [ $? -eq 0 ]; then
            log_message "Successfully renamed: $file to $new_name"
        else
            log_message "Error: Failed to rename $file"
        fi
    else
        log_message "File does not match renaming criteria: $file"
    fi
}

# Export the function so it can be used by xargs
export -f rename_file
export -f log_message

# Log the directories being watched
log_message "Watching directories: ${WATCH_DIRS[*]}"

# Use fswatch to monitor the directories and call rename_file for each new file
if ! fswatch -0 --event Created "${WATCH_DIRS[@]}" | xargs -0 -n 1 -I {} bash -c 'rename_file "$@"' _ {}; then
    log_message "Error: fswatch command failed"
    exit 1
fi

log_message "DuplicateWithTimestamp.sh stopped"

