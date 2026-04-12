// swift-tools-version: 6.0

import PackageDescription
import Foundation

let package = Package(
    name: "SilkEmu",
    products: [
        .library(
            name: "SilkSystem",
            targets: ["SilkSystem"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/cricut/FishyJoes", .upToNextMajor(from: "7.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "silk-emu",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SilkSystem"),
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
        .target(name: "SilkRAM"),
        .testTarget(
            name: "SilkRAMTests",
            dependencies: [
                .target(name: "SilkRAM"),
            ]
        ),
        .target(name: "SilkROM"),
        .testTarget(
            name: "SilkROMTests",
            dependencies: [
                .target(name: "SilkROM"),
            ]
        ),
        .target(name: "SilkVIA"),
        .testTarget(
            name: "SilkVIATests",
            dependencies: [
                .target(name: "SilkVIA"),
            ]
        ),
        .target(name: "SilkACIA"),
        .testTarget(
            name: "SilkACIATests",
            dependencies: [
                .target(name: "SilkACIA"),
            ]
        ),
        .target(name: "SilkLCD"),
        .testTarget(
            name: "SilkLCDTests",
            dependencies: [
                .target(name: "SilkLCD"),
            ]
        ),
        .target(
            name: "SilkSystem",
            dependencies: [
                .target(name: "SilkCPU"),
                .target(name: "SilkRAM"),
                .target(name: "SilkROM"),
                .target(name: "SilkVIA"),
                .target(name: "SilkACIA"),
                .target(name: "SilkLCD"),
            ]
        ),
        .testTarget(
            name: "SilkSystemTests",
            dependencies: [
                .target(name: "SilkSystem"),
            ]
        )
    ]
)
