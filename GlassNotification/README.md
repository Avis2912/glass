# Glass Notification - Native macOS App

A beautiful, native macOS application that displays sleek glass translucent notifications whenever you select text anywhere on your system.

## Features

- 🎨 **Beautiful Glass Design**: Native macOS glassmorphism with blur effects
- 🌍 **System-Wide Detection**: Works across all applications and websites
- ⚡ **Instant Notifications**: Appears immediately when text is selected
- ⏰ **Auto-Dismiss**: Automatically disappears after 3 seconds
- 🎯 **Smart Positioning**: Always appears in the bottom-right corner
- 🔒 **Privacy Focused**: Only monitors text selection, nothing else

## Screenshots

The notification features:
- Translucent background with blur effect
- Smooth fade-in and fade-out animations
- Native macOS styling with system fonts
- Checkmark icon indicating successful text selection
- Truncated text preview (up to 100 characters)

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for building from source)
- Accessibility permissions (automatically requested)

## Installation

### Option 1: Build from Source

1. **Clone or download** this project
2. **Open Terminal** and navigate to the project directory:
   ```bash
   cd /path/to/GlassNotification
   ```
3. **Build the app**:
   ```bash
   ./build.sh
   ```
4. **Create an app bundle** (optional, for easier launching):
   ```bash
   ./create_app_bundle.sh
   ```

### Option 2: Pre-built App

If you have a pre-built version, simply:
1. Double-click the `.app` file
2. Grant accessibility permissions when prompted
3. The app will run in the background with a menu bar icon

## How to Use

1. **Launch the app** - it will appear in your menu bar (top-right of screen)
2. **Grant permissions** - when prompted, allow accessibility access in System Preferences
3. **Select text anywhere** - in Safari, Notes, Messages, or any app
4. **Watch the magic** - a beautiful glass notification appears instantly!

## Accessibility Permissions

The app requires accessibility permissions to detect text selection across all applications. When you first run the app:

1. A dialog will appear asking for accessibility permissions
2. Click "Open System Preferences"
3. Find "Glass Notification" in the list
4. Check the box next to it
5. Restart the app

## Customization

The notification appearance can be customized by modifying the Swift code:

- **Colors**: Change the glass background opacity and colors
- **Animation**: Adjust timing and easing functions
- **Position**: Modify the screen positioning logic
- **Size**: Change the notification dimensions

## Technical Details

- Built with **Swift 5.9** and **SwiftUI**
- Uses **AppKit** for native macOS integration
- Leverages **Accessibility APIs** for system-wide text detection
- Implements **NSWindow** with custom styling for the glass effect

## Troubleshooting

### Notification doesn't appear
- Ensure accessibility permissions are granted
- Check that the app is running (look for menu bar icon)
- Try selecting text in different applications

### App won't start
- Verify you have macOS 12.0 or later
- Check that Xcode command line tools are installed
- Try rebuilding: `./build.sh`

### Performance issues
- The app uses minimal system resources
- Text monitoring occurs every 500ms
- Accessibility APIs are optimized for performance

## Privacy & Security

- Only monitors text selection events
- No data is stored or transmitted
- No internet connection required
- Open source for complete transparency

## Development

To modify the app:

1. Open the project in Xcode
2. Edit the Swift files as needed
3. Build and test on your Mac
4. Create a new app bundle for distribution

## License

This project is open source and available under the MIT License.

## Support

If you encounter issues or have suggestions:
- Check the troubleshooting section above
- Ensure your macOS version is supported
- Verify accessibility permissions are granted
- Try rebuilding the app from source

Enjoy your beautiful glass notifications! ✨

