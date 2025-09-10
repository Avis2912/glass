//
//  NotificationWindow.swift
//  GlassNotification
//
//  Created by Glass Notification App
//  Copyright © 2024 Glass Notification. All rights reserved.
//

import Cocoa
import SwiftUI

class NotificationWindow: NSWindow {

    private var hideTimer: Timer?

    init(text: String) {
        super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)

        // Configure window properties
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .transient]

        // Set up content
        let contentView = NotificationView(text: text)
        self.contentView = NSHostingView(rootView: contentView)

        // Position the window
        positionWindow()

        // Auto-hide after 3 seconds
        hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.hideWithAnimation()
        }
    }

    private func positionWindow() {
        guard let screen = NSScreen.main else { return }

        let windowWidth: CGFloat = 350
        let windowHeight: CGFloat = 80

        // Position in bottom right corner
        let x = screen.visibleFrame.maxX - windowWidth - 20
        let y = screen.visibleFrame.minY + 40

        self.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
    }

    func show() {
        // Animate in
        self.alphaValue = 0.0
        self.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1.0
        }
    }

    private func hideWithAnimation() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0.0
        } completionHandler: {
            self.close()
        }
    }

    override func close() {
        hideTimer?.invalidate()
        hideTimer = nil
        super.close()
    }
}

// SwiftUI view for the notification content
struct NotificationView: View {
    let text: String

    @State private var isVisible = true

    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 8)

            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 24, height: 24)

                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Text Selected")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.8))

                    Text(truncateText(text))
                        .font(.system(size: 12))
                        .foregroundColor(.primary.opacity(0.6))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(20)
        }
        .frame(width: 350, height: 80)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = true
            }

            // Start fade out animation 2.5 seconds in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    isVisible = false
                }
            }
        }
    }

    private func truncateText(_ text: String) -> String {
        let maxLength = 100
        if text.count <= maxLength {
            return text
        }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength - 3)
        return String(text[..<endIndex]) + "..."
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(text: "This is a sample text selection that will be truncated if it's too long to fit in the notification.")
            .frame(width: 350, height: 80)
            .background(Color.gray.opacity(0.1))
    }
}

