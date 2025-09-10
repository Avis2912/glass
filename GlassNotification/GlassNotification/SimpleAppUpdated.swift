//
//  SimpleAppUpdated.swift
//  GlassNotification
//
//  Updated version with top-right positioning, pill shape, and smooth animations
//

import Cocoa

class SimpleApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var apiKey: String = "" // Will be set by user
    
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
        menu.addItem(NSMenuItem(title: "Set API Key", action: #selector(setAPIKey), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Restart App", action: #selector(restartApp), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        print("✅ Menu created")
        
        // Request accessibility permissions
        requestAccessibilityPermission()
        
        // Load saved API key
        loadAPIKey()
        
        // Start global text selection monitoring
        startTextSelectionMonitoring()
        
        // Set up global keyboard shortcuts
        setupGlobalKeyboardShortcuts()
        
        // Keep app running
        NSApp.setActivationPolicy(.accessory)
        print("✅ App setup complete - look for 💬 in menu bar!")
        print("💡 HOW TO USE: Select text anywhere - notification stays until you press Cmd+Shift+F!")
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
        print("🔍 Starting automatic text selection monitoring...")
        
        // Monitor mouse events for text selection
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
        
        // Also check periodically (but less frequently)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkForTextSelection()
        }
        
        print("✅ Automatic text selection monitoring started")
        print("💡 Usage: Just select text anywhere - notification will appear automatically")
    }
    
    var lastSelectedText = ""
    var currentNotificationWindow: NSWindow?
    
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
        
        guard result == .success, let element = focusedElement else { 
            // Clear last selected text when no element is focused
            if !lastSelectedText.isEmpty {
                lastSelectedText = ""
                print("🔄 Selection cleared")
            }
            return 
        }
        
        // Try to get selected text
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textResult == .success, let text = selectedText as? String, !text.isEmpty {
            // Only show notification if text is different from last time
            if text != lastSelectedText && text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                lastSelectedText = text
                print("📝 Text selected: \(text.prefix(50))...")
                
                // Close existing notification if any
                if let existingWindow = currentNotificationWindow {
                    existingWindow.close()
                    currentNotificationWindow = nil
                }
                
                showNotificationWithText(text)
            }
        } else {
            // Clear last selected text when no text is selected
            if !lastSelectedText.isEmpty {
                lastSelectedText = ""
                print("🔄 Selection cleared")
            }
        }
    }
    
    func showNotificationWithText(_ text: String) {
        print("🎉 Showing sleek glass notification")

        // Create a sleeker window (smaller width)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 150),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Configure window properly
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .floating
        window.ignoresMouseEvents = false // Allow keyboard events for shortcuts
        window.collectionBehavior = [.canJoinAllSpaces, .transient]
        
        // Add keyboard shortcut handling
        window.acceptsMouseMovedEvents = true
        window.makeFirstResponder(window.contentView)

        // Position in top right corner
        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 370
            let y = screen.visibleFrame.maxY - 140 // Top right with more space
            window.setFrame(NSRect(x: x, y: y, width: 350, height: 120), display: true)
        }

        // Create blurry dark glass background
        let backgroundView = NSView(frame: NSRect(x: 0, y: 0, width: 350, height: 120))
        backgroundView.wantsLayer = true
        
        // Dark translucent background with blur effect
        backgroundView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        backgroundView.layer?.cornerRadius = 15
        backgroundView.layer?.borderWidth = 0.5
        backgroundView.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        
        // Add blur effect (macOS visual effect)
        let visualEffectView = NSVisualEffectView(frame: backgroundView.bounds)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 15
        backgroundView.addSubview(visualEffectView)
        
        // Add dramatic shadow
        backgroundView.shadow = NSShadow()
        backgroundView.shadow?.shadowOffset = NSSize(width: 0, height: -4)
        backgroundView.shadow?.shadowBlurRadius = 20
        backgroundView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.4)

        // Add selected text (left aligned, no quotes)
        let truncatedText = text.count > 80 ? String(text.prefix(80)) + "..." : text
        let selectedTextLabel = NSTextField(wrappingLabelWithString: truncatedText)
        selectedTextLabel.frame = NSRect(x: 20, y: 90, width: 310, height: 45)
        selectedTextLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        selectedTextLabel.textColor = NSColor.white
        selectedTextLabel.alignment = .left
        selectedTextLabel.maximumNumberOfLines = 2

        // Add streaming AI response text below (starts empty, wrapping)
        let aiResponseLabel = NSTextField(wrappingLabelWithString: "")
        aiResponseLabel.frame = NSRect(x: 20, y: 15, width: 310, height: 60)
        aiResponseLabel.font = NSFont.systemFont(ofSize: 14, weight: .light)
        aiResponseLabel.textColor = NSColor.lightGray
        aiResponseLabel.alignment = .left
        aiResponseLabel.maximumNumberOfLines = 4
        aiResponseLabel.alphaValue = 0

        // Add all views
        visualEffectView.addSubview(selectedTextLabel)
        visualEffectView.addSubview(aiResponseLabel)
        window.contentView = backgroundView
        
        // Store reference to current window
        currentNotificationWindow = window
        
        // Show with smooth slide-in animation from right
        window.alphaValue = 0
        let originalFrame = window.frame
        let startFrame = NSRect(x: originalFrame.origin.x + 50, y: originalFrame.origin.y, width: originalFrame.width, height: originalFrame.height)
        window.setFrame(startFrame, display: false)
        window.makeKeyAndOrderFront(nil)
        
        // Smooth slide-in and fade-in animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1
            window.animator().setFrame(originalFrame, display: true)
        }
        
        // Get AI response for the selected text after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.getAIResponse(for: text) { response in
                DispatchQueue.main.async {
                    // Fade in the label first
                    NSAnimationContext.runAnimationGroup { context in
                        context.duration = 0.3
                        aiResponseLabel.animator().alphaValue = 1
                    }
                    
                    // Super smooth typewriter effect for AI response
                    let words = response.components(separatedBy: " ")
                    var wordIndex = 0
                    var charInWordIndex = 0
                    
                    let _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                        if wordIndex < words.count {
                            let currentWord = words[wordIndex]
                            
                            if charInWordIndex < currentWord.count {
                                // Add character by character within word
                                let charIndex = currentWord.index(currentWord.startIndex, offsetBy: charInWordIndex)
                                let partialWord = String(currentWord[..<currentWord.index(after: charIndex)])
                                
                                let displayText = words[0..<wordIndex].joined(separator: " ") + 
                                                (wordIndex > 0 ? " " : "") + partialWord
                                
                                aiResponseLabel.stringValue = displayText
                                charInWordIndex += 1
                            } else {
                                // Move to next word
                                wordIndex += 1
                                charInWordIndex = 0
                                
                                // Add space and show complete words so far
                                let displayText = words[0..<wordIndex].joined(separator: " ")
                                aiResponseLabel.stringValue = displayText
                            }
                        } else {
                            timer.invalidate()
                        }
                    }
                }
            }
        }

        // No auto-hide - stays until user presses Cmd+Shift+F
    }
    
    @objc func testNotification() {
        print("🧪 Test sleek glass notification")
        showNotificationWithText("This is your selected text that will appear beautifully")
    }
    
    @objc func setAPIKey() {
        let alert = NSAlert()
        alert.messageText = "Set OpenAI API Key"
        alert.informativeText = "Enter your OpenAI API key to enable AI responses:"
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        inputTextField.placeholderString = "sk-..."
        alert.accessoryView = inputTextField
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let key = inputTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty {
                apiKey = key
                print("✅ API key set")
                
                // Save to UserDefaults
                UserDefaults.standard.set(key, forKey: "OpenAI_API_Key")
            }
        }
    }
    
    @objc func restartApp() {
        print("🔄 Restarting app...")
        
        // Close current notification if any
        currentNotificationWindow?.close()
        currentNotificationWindow = nil
        
        // Clear state
        lastSelectedText = ""
        
        // Get the current executable path
        let executablePath = ProcessInfo.processInfo.arguments[0]
        
        // Start new instance
        let task = Process()
        task.executableURL = URL(fileURLWithPath: executablePath)
        
        do {
            try task.run()
            // Quit current instance
            NSApp.terminate(nil)
        } catch {
            print("❌ Failed to restart: \(error)")
        }
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    // Load API key from UserDefaults on startup
    func loadAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: "OpenAI_API_Key") {
            apiKey = savedKey
            print("✅ API key loaded from preferences")
        }
    }
    
    // Set up global keyboard shortcuts
    func setupGlobalKeyboardShortcuts() {
        // Add global monitor for Command+Q to close notification
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let hasCommand = event.modifierFlags.contains(.command)
            let hasShift = event.modifierFlags.contains(.shift)
            let isF = event.charactersIgnoringModifiers == "f"
            
            if hasCommand && hasShift && isF {
                print("🔥 DEBUG: Global Cmd+Shift+F detected!")
                print("🔥 DEBUG: hasCommand=\(hasCommand), hasShift=\(hasShift), isF=\(isF)")
                print("🔥 DEBUG: currentNotificationWindow exists: \(self?.currentNotificationWindow != nil)")
                if let window = self?.currentNotificationWindow {
                    print("⌨️ Cmd+Shift+F detected - closing notification")
                    self?.hideNotificationWithAnimation(window: window)
                } else {
                    print("❌ No notification window to close")
                }
            }
        }
        
        // Also add local monitor for when our window is key
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let hasCommand = event.modifierFlags.contains(.command)
            let hasShift = event.modifierFlags.contains(.shift)
            let isF = event.charactersIgnoringModifiers == "f"
            
            if hasCommand && hasShift && isF {
                print("🔥 DEBUG: Local Cmd+Shift+F detected!")
                print("🔥 DEBUG: hasCommand=\(hasCommand), hasShift=\(hasShift), isF=\(isF)")
                print("🔥 DEBUG: currentNotificationWindow exists: \(self?.currentNotificationWindow != nil)")
                if let window = self?.currentNotificationWindow {
                    print("⌨️ Local Cmd+Shift+F detected - closing notification")
                    self?.hideNotificationWithAnimation(window: window)
                    return nil // Consume the event
                } else {
                    print("❌ No notification window to close")
                }
            }
            return event
        }
        
        print("✅ Global keyboard shortcuts set up")
    }
    
    // Animate notification hide
    func hideNotificationWithAnimation(window: NSWindow) {
        print("🔥 DEBUG: hideNotificationWithAnimation called")
        print("🔥 DEBUG: window == currentNotificationWindow: \(window == currentNotificationWindow)")
        
        // Make sure this window is still valid
        guard window == currentNotificationWindow else { 
            print("❌ DEBUG: Window mismatch - not closing")
            return 
        }
        
        print("✅ DEBUG: Starting close animation")
        let originalFrame = window.frame
        let endFrame = NSRect(x: originalFrame.origin.x + 50, y: originalFrame.origin.y, width: originalFrame.width, height: originalFrame.height)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
            window.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            print("✅ DEBUG: Animation complete - closing window")
            window.close()
            self.currentNotificationWindow = nil
            print("✅ DEBUG: Window closed and cleared")
        })
    }
    
    // AI Response function using OpenAI API with timeout
    func getAIResponse(for text: String, completion: @escaping (String) -> Void) {
        print("🔥 DEBUG: getAIResponse called with text: '\(text.prefix(50))...'")
        
        guard !apiKey.isEmpty else {
            print("❌ DEBUG: No API key found")
            completion("Set your API key in the menu to enable AI responses.")
            return
        }
        
        print("✅ DEBUG: API key exists, making request")
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0 // 10 second timeout
        
        let prompt = "Explain the meaning or significance of this text in 2-3 sentences: \"\(text)\""
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 80,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion("Failed to create request.")
            return
        }
        
        // Create session with timeout configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        let session = URLSession(configuration: config)
        
        print("🚀 DEBUG: Starting API request task")
        let task = session.dataTask(with: request) { data, response, error in
            print("📡 DEBUG: API response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Request timed out or failed.")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion("API request failed (\(httpResponse.statusCode))")
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("No response received.")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        DispatchQueue.main.async {
                            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    } else if let error = json["error"] as? [String: Any],
                              let errorMessage = error["message"] as? String {
                        DispatchQueue.main.async {
                            completion("API Error: \(errorMessage)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("Unable to parse response.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("Invalid response format.")
                    }
                }
            } catch {
                print("❌ JSON Parse error: \(error)")
                DispatchQueue.main.async {
                    completion("Failed to parse response.")
                }
            }
        }
        
        task.resume()
        
        // Backup timeout - if nothing happens in 12 seconds, force completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            task.cancel()
            completion("Request timed out.")
        }
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = SimpleApp()
app.delegate = delegate
app.run()
