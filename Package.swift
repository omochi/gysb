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
        .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "0.8.21")
    ],
    targets: [
        .target(name: "GysbBase",
                dependencies: ["Cryptor"]),
        .target(name: "GysbKit",
                dependencies: ["GysbBase"]),
        .target(name: "gysb",
                dependencies: ["GysbKit"]),
        .testTarget(name: "GysbKitTest",
                    dependencies: ["GysbKit"])
    ]
)
