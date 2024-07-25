#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -x  # Print commands and their arguments as they are executed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL_APP="$SCRIPT_DIR/original-unsigned/DuplicateWithTimestamp.app"
CLEAN_APP="$SCRIPT_DIR/cleaned-and-signed/DuplicateWithTimestamp.app"

# Step 1: Remove the existing clean app if it exists
echo "Removing existing clean app..."
rm -rf "$CLEAN_APP"

# Step 2: Create the directory for the cleaned app if it doesn't exist
echo "Creating directory for cleaned app..."
mkdir -p "$(dirname "$CLEAN_APP")"

# Step 3: Create a new, empty app bundle
echo "Creating new app bundle..."
mkdir -p "$CLEAN_APP/Contents/MacOS"
mkdir -p "$CLEAN_APP/Contents/Resources"

# Step 4: Copy necessary files
echo "Copying necessary files..."
cp -R "$ORIGINAL_APP/Contents/Info.plist" "$CLEAN_APP/Contents/"
cp -R "$ORIGINAL_APP/Contents/MacOS/"* "$CLEAN_APP/Contents/MacOS/"
cp -R "$ORIGINAL_APP/Contents/Resources/"* "$CLEAN_APP/Contents/Resources/"
cp -R "$ORIGINAL_APP/Contents/document.wflow" "$CLEAN_APP/Contents/"

# Step 5: Remove all extended attributes from the new app bundle
echo "Removing all extended attributes..."
xattr -cr "$CLEAN_APP"

# Step 6: Sign the cleaned app bundle
echo "Signing the cleaned app bundle..."
codesign --sign "Developer ID Application: Parker Brooks (6RLN3QRWBQ)" \
--force \
--options runtime \
--verbose \
--deep \
--preserve-metadata=identifier,entitlements,flags \
--timestamp \
--strict \
"$CLEAN_APP"

# Step 7: Verify the signature
echo "Verifying the signature..."
codesign --verify --deep --strict --verbose=4 "$CLEAN_APP"

# Step 8: Check for any remaining extended attributes
echo "Checking for any remaining extended attributes..."
xattr -lr "$CLEAN_APP"

# Step 9: Final verification
echo "Final verification..."
codesign --verify --deep --strict --verbose=4 "$CLEAN_APP"

echo "Process completed. Cleaned and signed app is located at: $CLEAN_APP"
