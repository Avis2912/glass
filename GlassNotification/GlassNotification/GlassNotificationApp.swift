//
//  GlassNotificationApp.swift
//  GlassNotification
//
//  Created by Glass Notification App
//  Copyright © 2024 Glass Notification. All rights reserved.
//

import SwiftUI

@main
struct GlassNotificationApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene since we use NSApplicationDelegate
        Settings {
            EmptyView()
        }
    }
}

