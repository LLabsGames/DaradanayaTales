// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DaradanayaTales",
    platforms: [
        SupportedPlatform.iOS(.v15),
        SupportedPlatform.macOS(.v14)
    ],
    products: [
        .executable(
            name: "DaradanayaTales",
            targets: ["DaradanayaTales"]),
        .library(
            name: "DaradanayaDriver",
            type: .dynamic,
            targets: ["DaradanayaDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "fe24cb01640c2d4d48c8555a71adfe346d9543cf"),
        .package(url: "https://github.com/migueldeicaza/SwiftGodotKit", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "DaradanayaTales",
            dependencies: [
                "DaradanayaDriver",
                .product(name: "SwiftGodotKit", package: "SwiftGodotKit")
            ],
            resources: [
                .copy("Resources/DaradanayaDriver.pck"),
                .copy("../../godot")
            ]),
        .target(
            name: "DaradanayaDriver",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodot")
            ]),
    ]
)
