#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to display usage instructions
usage() {
    echo "Usage: $0 <dylib> <app_path>"
    echo "  dylib      - The dynamic library to inject."
    echo "  app_path   - The path to the .app bundle."
    exit 1
}

# Ensure required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "[ERROR] Incorrect number of arguments."
    usage
fi

DYLIB=$1
APP_PATH=$2

# Validate inputs
if [ ! -f "$DYLIB" ]; then
    echo "[ERROR] The specified dynamic library ($DYLIB) does not exist."
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "[ERROR] The specified app path ($APP_PATH) does not exist."
    exit 1
fi

INFO_PLIST_PATH="$APP_PATH/Contents/Info.plist"
if [ ! -f "$INFO_PLIST_PATH" ]; then
    echo "[ERROR] Info.plist not found at $INFO_PLIST_PATH"
    exit 1
fi

# Get the executable name from Info.plist
APP_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" "$INFO_PLIST_PATH")
if [ -z "$APP_NAME" ]; then
    echo "[ERROR] Could not read CFBundleExecutable from $INFO_PLIST_PATH"
    exit 1
fi

echo "[INFO] Executable name: $APP_NAME"

EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/$APP_NAME"
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "[ERROR] The specified executable ($EXECUTABLE_PATH) does not exist."
    exit 1
fi

# Ensure Resources folder exists
mkdir -p "$APP_PATH/Contents/Resources/"

# Copy the dylib to the Resources folder
cp "$DYLIB" "$APP_PATH/Contents/Resources/"
echo "[INFO] Copied $DYLIB to $APP_PATH/Contents/Resources/"

# # Remove existing code signature
# codesign --remove-signature "$EXECUTABLE_PATH"
# echo "[INFO] Removed existing code signature from $EXECUTABLE_PATH"

# Inject the dylib using optool
optool install -c load -p "@executable_path/../Resources/$(basename "$DYLIB")" -t "$EXECUTABLE_PATH"
echo "[INFO] Injected $DYLIB into $EXECUTABLE_PATH"

# Re-sign the application
sudo codesign -f -s - --timestamp=none --all-architectures --deep "$APP_PATH"
sudo xattr -cr "$APP_PATH"
echo "[INFO] Re-signed $APP_PATH"

exit 0