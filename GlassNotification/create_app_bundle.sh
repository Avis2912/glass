#!/bin/bash

# Create macOS app bundle for Glass Notification

echo "Creating Glass Notification.app bundle..."

# Build first
swift build --configuration release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="Glass Notification"
BUNDLE_NAME="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_NAME}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean up existing bundle
rm -rf "${BUNDLE_NAME}"

# Create directories
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp ".build/release/GlassNotification" "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist
cp "GlassNotification/Info.plist" "${CONTENTS_DIR}/"

# Create PkgInfo
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "App bundle created: ${BUNDLE_NAME}"
echo ""
echo "To run the app:"
echo "  open \"${BUNDLE_NAME}\""
echo ""
echo "Or move it to Applications:"
echo "  mv \"${BUNDLE_NAME}\" /Applications/"

