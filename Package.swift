// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SilkEmu",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SilkEmu",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SilkCPU"),
            ]
        ),
        .target(name: "SilkCPU"),
        .testTarget(
            name: "SilkCPUTests",
            dependencies: [
                .target(name: "SilkCPU"),
            ]
        )
    ]
)
