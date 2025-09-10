//
//  AppDelegate.swift
//  GlassNotification
//
//  Created by Glass Notification App
//  Copyright © 2024 Glass Notification. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var notificationWindow: NotificationWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            // Use emoji as primary icon - guaranteed to work
            button.title = "💬"
            button.toolTip = "Glass Notification - Click for menu"
        }

        // Create menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Glass Notification", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        // Request accessibility permissions
        requestAccessibilityPermission()

        // Start text selection monitoring
        startTextSelectionMonitoring()

        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Glass Notification"
        alert.informativeText = "A sleek macOS notification app that shows beautiful glass notifications when you select text anywhere on your system."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "Glass Notification needs accessibility permissions to detect text selection across all applications. Please enable it in System Preferences > Security & Privacy > Privacy > Accessibility."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Later")

            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }

    func startTextSelectionMonitoring() {
        // Monitor for text selection changes using accessibility
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp, .keyUp]) { [weak self] event in
            self?.checkForTextSelection()
        }

        // Also monitor periodically
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForTextSelection()
        }
    }

    func checkForTextSelection() {
        guard NSWorkspace.shared.frontmostApplication != nil else { return }

        // Get the currently focused element
        guard let focusedElement = AXUIElementCreateSystemWide().focusedElement else { return }

        // Try to get selected text
        var selectedText: AnyObject?
        let result = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextAttribute as CFString, &selectedText)

        if result == .success, let text = selectedText as? String, !text.isEmpty {
            showNotification(with: text)
        }
    }

    func showNotification(with text: String) {
        // Close existing notification if any
        notificationWindow?.close()

        // Create new notification window
        notificationWindow = NotificationWindow(text: text)
        notificationWindow?.show()
    }
}

// Helper extension for AXUIElement
extension AXUIElement {
    var focusedElement: AXUIElement? {
        var focused: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXFocusedUIElementAttribute as CFString, &focused)
        return result == .success ? (focused as! AXUIElement) : nil
    }
}
