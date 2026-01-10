// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SilkEmu",
    products: [
        .library(name: "SilkCPU", targets: ["SilkCPU"]),
        .library(name: "SilkVIA", targets: ["SilkVIA"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "silk-emu",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SilkCPU"),
                .target(name: "SilkVIA"),
            ],
            path: "Sources/SilkEmu"
        ),
        .target(name: "SilkCPU"),
        .testTarget(
            name: "SilkCPUTests",
            dependencies: [
                .target(name: "SilkCPU"),
            ]
        ),
        .target(name: "SilkVIA"),
        .testTarget(
            name: "SilkVIATests",
            dependencies: [
                .target(name: "SilkVIA"),
            ]
        )
    ]
)
