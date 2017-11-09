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
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/CommonCrypto.git", from: "0.1.5")
    ],
    targets: [
        .target(name: "GysbBase"),
        .target(name: "GysbSwiftConfig",
                dependencies: ["GysbBase"]),
        .target(name: "GysbMacroLib",
                dependencies: ["GysbBase"]),
        .target(name: "GysbKit",
                dependencies: ["GysbBase", "GysbSwiftConfig", "GysbMacroLib"]),
        .target(name: "gysb",
                dependencies: ["GysbKit"]),
        .testTarget(name: "GysbKitTest",
                    dependencies: ["GysbKit"])
    ]
)
