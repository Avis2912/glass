#!/bin/bash

echo "🔄 Restarting Glass Notification App..."

# Kill existing instances
pkill -f GlassNotification

# Wait a moment
sleep 1

# Navigate to the correct directory
cd /Users/avi/Desktop/glass/GlassNotification

# Build and run
swift build && ./.build/debug/GlassNotification &

echo "✅ Glass Notification restarted!"
echo "💡 Usage: Select text anywhere, then press Cmd+E to analyze it"
echo "🎯 Look for 💬 emoji in your menu bar"
