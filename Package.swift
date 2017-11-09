// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gysb",
    products: [
        .library(
            name: "GysbKit",
            type: .dynamic,
            targets: ["GysbKit"]
        ),
        .executable(
            name: "gysb",
            targets: ["gysb"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GysbBase"),
        .target(
            name: "GysbMacroLib",
            dependencies: ["GysbBase"]),
        .target(
            name: "GysbKit",
            dependencies: ["GysbBase", "GysbMacroLib"]),
        .target(
            name: "gysb",
            dependencies: ["GysbKit"]),
        .testTarget(
            name: "GysbKitTest",
            dependencies: ["GysbKit"])
    ]
)
