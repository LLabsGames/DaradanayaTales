// swift-tools-version: 5.9

import PackageDescription

let hBird = "https://github.com/hummingbird-project/hummingbird.git"
let argPr = "https://github.com/apple/swift-argument-parser.git"
let pgNio = "https://github.com/vapor/postgres-nio.git"
let async = "https://github.com/swift-server/async-http-client.git"
let tgApi = "https://github.com/nerzh/swift-telegram-sdk"

let package = Package(
    name: "DaradanayaTales",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: hBird, from: "2.0.0-rc.2"),
        .package(url: argPr, from: "1.4.0"),
        .package(url: pgNio, from: "1.21.0"),
        .package(url: tgApi, from: "3.3.3"),
        .package(url: async, from: "1.21.2")
    ],
    targets: [
        .executableTarget(
            name: "DaradanayaTales",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "_ConnectionPoolModule", package: "postgres-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "SwiftTelegramSdk", package: "swift-telegram-sdk"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
            ]
        ),
        .testTarget(
            name: "DaradanayaTalesTests",
            dependencies: [
                "DaradanayaTales",
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ]
        ),
    ]
)
