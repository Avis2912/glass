#!/bin/bash

# Build script for Glass Notification macOS app

echo "Building Glass Notification..."

# Build the Swift package
swift build --configuration release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "The app is located at: $(pwd)/.build/release/GlassNotification"
    echo ""
    echo "To run the app:"
    echo "  $(pwd)/.build/release/GlassNotification"
    echo ""
    echo "Or create an app bundle:"
    echo "  ./create_app_bundle.sh"
else
    echo "Build failed!"
    exit 1
fi

