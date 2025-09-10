//
//  SimpleApp.swift
//  GlassNotification
//
//  A minimal test to ensure the menu bar icon appears
//

import Cocoa

class SimpleApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App starting...")
        
        // Create status bar item with fixed length
        statusItem = NSStatusBar.system.statusItem(withLength: 30)
        
        // Set the button properties
        if let button = statusItem.button {
            button.title = "💬"
            button.toolTip = "Glass Notification - Text Selection Monitor"
            print("✅ Status item created with emoji")
        } else {
            print("❌ Failed to create status item button")
        }
        
        // Create simple menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Test Notification", action: #selector(testNotification), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        print("✅ Menu created")
        
        // Request accessibility permissions
        requestAccessibilityPermission()
        
        // Start global text selection monitoring
        startTextSelectionMonitoring()
        
        // Keep app running
        NSApp.setActivationPolicy(.accessory)
        print("✅ App setup complete - look for 💬 in menu bar!")
    }
    
    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if trusted {
            print("✅ Accessibility permissions granted")
        } else {
            print("⚠️ Accessibility permissions needed - dialog should appear")
        }
    }
    
    func startTextSelectionMonitoring() {
        print("🔍 Starting text selection monitoring...")
        
        // Monitor mouse events for text selection
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.checkForTextSelection()
            }
        }
        
        // Monitor keyboard events (arrow keys, etc.)
        NSEvent.addGlobalMonitorForEvents(matching: [.keyUp]) { [weak self] event in
            // Only check for keys that might change selection
            if ["Left", "Right", "Up", "Down", "Home", "End"].contains(event.charactersIgnoringModifiers) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.checkForTextSelection()
                }
            }
        }
        
        // Also check periodically
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForTextSelection()
        }
        
        print("✅ Text selection monitoring started")
    }
    
    var lastSelectedText = ""
    
    func checkForTextSelection() {
        // Get the currently focused application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return }
        
        // Skip our own app
        if frontmostApp.bundleIdentifier == Bundle.main.bundleIdentifier {
            return
        }
        
        // Get the system-wide focused element
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        
        let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard result == .success, let element = focusedElement else { return }
        
        // Try to get selected text
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textResult == .success, let text = selectedText as? String, !text.isEmpty {
            // Only show notification if text is different from last time
            if text != lastSelectedText && text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                lastSelectedText = text
                print("📝 Text selected: \(text.prefix(50))...")
                showNotificationWithText(text)
            }
        }
    }
    
    func showNotificationWithText(_ text: String) {
        print("🎉 Showing notification for selected text")
        
        // Create a proper notification window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 80),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        // Configure window properly
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .transient]
        
        // Position in top right corner
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 370
            let y = screen.visibleFrame.maxY - 120 // Top right instead of bottom
            window.setFrame(NSRect(x: x, y: y, width: 350, height: 80), display: true)
        }
        
        // Create glass background with 100% border radius (pill shape)
        let backgroundView = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 80))
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.8).cgColor
        backgroundView.layer?.cornerRadius = 40 // 100% border radius (half of height)
        
        // Add subtle border
        backgroundView.layer?.borderWidth = 1
        backgroundView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        
        // Add shadow
        backgroundView.shadow = NSShadow()
        backgroundView.shadow?.shadowOffset = NSSize(width: 0, height: -5)
        backgroundView.shadow?.shadowBlurRadius = 15
        backgroundView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.3)
        
        // Add icon
        let iconView = NSTextField(labelWithString: "✓")
        iconView.frame = NSRect(x: 20, y: 30, width: 30, height: 30)
        iconView.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        iconView.textColor = NSColor.systemBlue
        iconView.alignment = .center
        
        // Add title
        let titleLabel = NSTextField(labelWithString: "Text Selected")
        titleLabel.frame = NSRect(x: 60, y: 45, width: 200, height: 20)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = NSColor.labelColor
        
        // Add selected text (truncated if too long)
        let truncatedText = text.count > 80 ? String(text.prefix(80)) + "..." : text
        let messageLabel = NSTextField(labelWithString: truncatedText)
        messageLabel.frame = NSRect(x: 60, y: 20, width: 270, height: 20)
        messageLabel.font = NSFont.systemFont(ofSize: 12)
        messageLabel.textColor = NSColor.secondaryLabelColor
        
        // Add all views
        backgroundView.addSubview(iconView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(messageLabel)
        window.contentView = backgroundView
        
        // Show with animation
        window.alphaValue = 0
        window.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 1
        }
        
        // Auto hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.close()
            })
        }
    }
    
    @objc func testNotification() {
        print("🧪 Test notification clicked")
        showTestNotification()
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    func showTestNotification() {
        print("🎉 Showing test notification")
        
        // Create a proper notification window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 80),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        // Configure window properly
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .floating
        window.ignoresMouseEvents = true  // This prevents cursor spinning!
        window.collectionBehavior = [.canJoinAllSpaces, .transient]
        
        // Position in bottom right corner
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 370
            let y = screen.visibleFrame.minY + 40
            window.setFrame(NSRect(x: x, y: y, width: 350, height: 80), display: true)
        }
        
        // Create glass background
        let backgroundView = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 80))
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.8).cgColor
        backgroundView.layer?.cornerRadius = 16
        
        // Add subtle border
        backgroundView.layer?.borderWidth = 1
        backgroundView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.3).cgColor
        
        // Add shadow
        backgroundView.shadow = NSShadow()
        backgroundView.shadow?.shadowOffset = NSSize(width: 0, height: -5)
        backgroundView.shadow?.shadowBlurRadius = 15
        backgroundView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.3)
        
        // Add icon
        let iconView = NSTextField(labelWithString: "✓")
        iconView.frame = NSRect(x: 20, y: 30, width: 30, height: 30)
        iconView.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        iconView.textColor = NSColor.systemBlue
        iconView.alignment = .center
        
        // Add title
        let titleLabel = NSTextField(labelWithString: "Text Selected")
        titleLabel.frame = NSRect(x: 60, y: 45, width: 200, height: 20)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = NSColor.labelColor
        
        // Add message
        let messageLabel = NSTextField(labelWithString: "Test notification is working! 🎉")
        messageLabel.frame = NSRect(x: 60, y: 20, width: 270, height: 20)
        messageLabel.font = NSFont.systemFont(ofSize: 12)
        messageLabel.textColor = NSColor.secondaryLabelColor
        
        // Add all views
        backgroundView.addSubview(iconView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(messageLabel)
        window.contentView = backgroundView
        
        // Show with animation
        window.alphaValue = 0
        window.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 1
        }
        
        // Auto hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.close()
            })
        }
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = SimpleApp()
app.delegate = delegate
app.run()
