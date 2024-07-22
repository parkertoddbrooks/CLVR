#!/bin/bash

# Enable error reporting and exit on error
set -e

# Navigate to the installer directory
cd "$(dirname "$0")"

echo "Starting package build process..."

# Create a temporary directory for the package contents
TEMP_DIR=$(mktemp -d)

# Copy scripts to the temporary directory
cp ../DuplicateWithTimestamp.sh "$TEMP_DIR/"
cp ../DuplicateFileManager.sh "$TEMP_DIR/"

# Copy the .app to the temporary directory
cp -R ../DuplicateWithTimestamp.app "$TEMP_DIR/"

# Create postinstall script
cat > "$TEMP_DIR/postinstall" << EOF
#!/bin/bash
mkdir -p "$HOME/.local/bin"
cp DuplicateWithTimestamp.sh "$HOME/.local/bin/"
cp DuplicateFileManager.sh "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/DuplicateWithTimestamp.sh"
chmod +x "$HOME/.local/bin/DuplicateFileManager.sh"

# Copy app to user's Applications folder
mkdir -p "$HOME/Applications"
cp -R DuplicateWithTimestamp.app "$HOME/Applications/"

# Add ~/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bash_profile"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi
EOF

# Make postinstall script executable
chmod +x "$TEMP_DIR/postinstall"

# Build the package
echo "Building the package..."
pkgbuild --root "$TEMP_DIR" \
         --scripts "$TEMP_DIR" \
         --identifier com.yourdomain.duplicatefileupdater \
         --version 1.0 \
         --install-location "$HOME/DuplicateFileUpdater" \
         DuplicateFileUpdater.pkg

# Clean up
rm -rf "$TEMP_DIR"

echo "Package build complete. The installer is now available as DuplicateFileUpdater.pkg"

# List the resulting package
ls -l DuplicateFileUpdater.pkg

echo "Next steps:"
echo "1. Test the package by double-clicking it to install."
echo "2. Verify that scripts are in ~/.local/bin and the app is in ~/Applications."
echo "3. Test the functionality of the installed components."