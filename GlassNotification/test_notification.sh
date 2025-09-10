#!/bin/bash

echo "🪟 Glass Notification Manual Test"
echo "================================"
echo ""

# Check if app is running
if ! pgrep -f "GlassNotification" > /dev/null; then
    echo "❌ App is not running. Starting it..."
    ./.build/debug/GlassNotification &
    sleep 2
fi

if pgrep -f "GlassNotification" > /dev/null; then
    echo "✅ Glass Notification is running"
    echo ""
    echo "🎯 Menu Bar Check:"
    echo "   • Look for 💬 emoji in your menu bar"
    echo "   • Click it to see the menu"
    echo "   • Try selecting text in any application"
    echo ""

    echo "🧪 Manual Notification Test:"
    echo "   Since automatic detection might need permissions,"
    echo "   let's manually test the notification window..."
    echo ""

    # Try to create a simple notification test
    echo "   1. Open the test_page.html in your browser"
    echo "   2. Select text there"
    echo "   3. Or try selecting text in Safari, Notes, or TextEdit"
    echo ""

    echo "🔐 If nothing happens, you need accessibility permissions:"
    echo "   System Preferences → Security & Privacy → Privacy → Accessibility"
    echo "   Add and enable 'GlassNotification'"

else
    echo "❌ Failed to start the app"
fi

echo ""
echo "Press Ctrl+C to exit"
while true; do
    sleep 1
    if ! pgrep -f "GlassNotification" > /dev/null; then
        echo "❌ App stopped running"
        break
    fi
done

