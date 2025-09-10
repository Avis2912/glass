#!/bin/bash

echo "🔍 Glass Notification Status Check"
echo "=================================="
echo ""

# Check if app is running
echo "📊 Process Check:"
if pgrep -f "GlassNotification" > /dev/null; then
    echo "✅ Glass Notification is running"
    ps aux | grep GlassNotification | grep -v grep
else
    echo "❌ Glass Notification is NOT running"
fi

echo ""
echo "🔧 Menu Bar Items:"
echo "   Look for any of these in your menu bar:"
echo "   • 💬 (speech bubble emoji)"
echo "   • Any small icon that looks like a notification"
echo "   • Right-click the menu bar area to see hidden items"

echo ""
echo "🔐 Accessibility Permissions:"
echo "   1. Open System Preferences"
echo "   2. Go to Security & Privacy → Privacy → Accessibility"
echo "   3. Look for 'Glass Notification' or 'GlassNotification'"
echo "   4. Make sure it's checked"

echo ""
echo "🧪 Quick Test:"
echo "   1. Open any app (Safari, Notes, TextEdit)"
echo "   2. Select some text"
echo "   3. Look for notification in bottom-right corner"

echo ""
echo "🚀 Starting App:"
echo "   Running the app now..."
./.build/debug/GlassNotification &
sleep 2

if pgrep -f "GlassNotification" > /dev/null; then
    echo "✅ App started successfully!"
    echo "   Check your menu bar for the 💬 icon"
else
    echo "❌ App failed to start"
fi

