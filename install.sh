#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create ~/.local/bin/ if it doesn't exist
mkdir -p ~/.local/bin

# Copy DuplicateWithTimestamp.sh to ~/.local/bin/
if [ -f "$SCRIPT_DIR/DuplicateWithTimestamp.sh" ]; then
    cp "$SCRIPT_DIR/DuplicateWithTimestamp.sh" ~/.local/bin/
    chmod +x ~/.local/bin/DuplicateWithTimestamp.sh
    echo "DuplicateWithTimestamp.sh has been copied and made executable."
else
    echo "Error: DuplicateWithTimestamp.sh not found in the script directory."
fi

# Copy DuplicateFileManager.sh to ~/.local/bin/
if [ -f "$SCRIPT_DIR/DuplicateFileManager.sh" ]; then
    cp "$SCRIPT_DIR/DuplicateFileManager.sh" ~/.local/bin/
    chmod +x ~/.local/bin/DuplicateFileManager.sh
    echo "DuplicateFileManager.sh has been copied and made executable."
else
    echo "Error: DuplicateFileManager.sh not found in the script directory."
fi

echo "Installation complete. Scripts have been copied to ~/.local/bin/ and made executable."