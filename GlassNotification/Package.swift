// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GlassNotification",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "GlassNotification", targets: ["GlassNotification"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GlassNotification",
            dependencies: [],
            path: "GlassNotification",
            sources: ["SimpleAppUpdated.swift"]
        )
    ]
)
