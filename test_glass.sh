#!/bin/bash

echo "🪟 Glass Notification Test Script"
echo "================================="
echo ""

# Check if app is running
echo "📊 Checking app status..."
if pgrep -f "GlassNotification" > /dev/null; then
    echo "✅ Glass Notification app is running!"
    echo "   Look for the speech bubble icon in your menu bar"
else
    echo "❌ App is not running"
    echo "   Starting app..."
    cd /Users/avi/Desktop/glass/GlassNotification
    ./.build/release/GlassNotification &
    sleep 2
fi

echo ""
echo "🔧 Accessibility Setup:"
echo "   1. Look for the speech bubble icon in your menu bar (top-right)"
echo "   2. If you see a permission dialog, click 'Open System Preferences'"
echo "   3. Find 'Glass Notification' and check the box"
echo ""

echo "🧪 Testing:"
echo "   1. Open the test_page.html in your browser"
echo "   2. Select any text on that page"
echo "   3. Watch for the glass notification in bottom-right!"
echo ""

echo "🎯 The notification will:"
echo "   • Appear instantly when you select text"
echo "   • Show a translucent glass design"
echo "   • Display the selected text (truncated if long)"
echo "   • Auto-disappear after 3 seconds"
echo ""

echo "Press Ctrl+C to exit this script"
echo "The app will continue running in the background"

# Keep script running
while true; do
    sleep 1
done

