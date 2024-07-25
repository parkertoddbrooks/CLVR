#!/bin/bash

# Set PATH to include common locations for tools
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# If Homebrew is installed, add its paths
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    log_message "fswatch is not installed. Installing fswatch..."
    brew install fswatch
fi

# Enable error handling
set -e

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$HOME/automator_workflow_debug.log"
}

log_message "Starting automator workflow..."

# Set the Resources directory path
RESOURCES_DIR="/Applications/DuplicateWithTimestamp.app/Contents/Resources"
log_message "Resources directory: $RESOURCES_DIR"

# Create ~/.local/bin/ if it doesn't exist
mkdir -p "$HOME/.local/bin"
log_message "Created ~/.local/bin/ directory"

# Function to copy file if it exists
copy_file() {
    local file="$1"
    if [ -f "$RESOURCES_DIR/$file" ]; then
        cp "$RESOURCES_DIR/$file" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/$file"
        log_message "Copied $file to ~/.local/bin/"
    else
        log_message "Error: $file not found in $RESOURCES_DIR"
    fi
}

# Copy necessary files
copy_file "DuplicateWithTimestamp.sh"
copy_file "DuplicateFileManager.sh"

# Function to update PATH in a file if not already present
update_path_in_file() {
    local file="$1"
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$file"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$file"
        log_message "Updated PATH in $file"
    else
        log_message "PATH already updated in $file"
    fi
}

# Update PATH if necessary
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    update_path_in_file "$HOME/.bash_profile"
    update_path_in_file "$HOME/.zshrc"
    export PATH="$HOME/.local/bin:$PATH"
    log_message "Updated PATH in current session"
else
    log_message "PATH already includes ~/.local/bin"
fi

# Verify files are copied and executable
if [ -x "$HOME/.local/bin/DuplicateWithTimestamp.sh" ] && [ -x "$HOME/.local/bin/DuplicateFileManager.sh" ]; then
    log_message "Verified: Scripts are copied and executable"
else
    log_message "Error: Scripts are not properly copied or not executable"
fi

# Test execution of copied scripts
if command -v DuplicateWithTimestamp.sh &> /dev/null && command -v DuplicateFileManager.sh &> /dev/null; then
    log_message "Verified: Scripts are accessible in PATH"
else
    log_message "Error: Scripts are not accessible in PATH"
fi


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

log_message "Open, check for required files, install if needed and run completed"






#!/bin/bash



log_message "Automator workflow completed."
