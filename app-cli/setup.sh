#!/bin/bash

echo "Starting installation of Duplicate File and Update Name with Timestamp..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "fswatch is not installed. Installing fswatch..."
    brew install fswatch
fi

# Create ~/.local/bin/ if it doesn't exist
mkdir -p ~/.local/bin

# Copy scripts to ~/.local/bin/
echo "Copying scripts to ~/.local/bin/..."
cp DuplicateWithTimestamp.sh ~/.local/bin/
cp DuplicateFileManager.sh ~/.local/bin/

# Make scripts executable
chmod +x ~/.local/bin/DuplicateWithTimestamp.sh
chmod +x ~/.local/bin/DuplicateFileManager.sh

# Add ~/.local/bin to PATH if it's not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "Installation complete!"
echo "Please restart your terminal or run 'source ~/.bash_profile' (or 'source ~/.zshrc' if using zsh) to update your PATH."
echo "You can now use the DuplicateFileManager.sh script to start and stop the service."