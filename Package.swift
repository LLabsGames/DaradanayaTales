// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DaradanayaTales",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .executable(name: "DaradanayaTales", targets: ["DaradanayaTales"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Maxim-Lanskoy/SwiftTelegramSDK.git", from: "3.4.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-rc.2"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-fluent.git", from: "2.0.0-beta.2")
    ],
    targets: [
        .executableTarget(name: "DaradanayaTales", dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "HummingbirdFluent", package: "hummingbird-fluent"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "SwiftTelegramSdk", package: "SwiftTelegramSDK")
            ], path: "Sources/DaradanayaTales", swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]),
        .testTarget(name: "AppTests", dependencies: [
                .byName(name: "DaradanayaTales"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ], path: "Tests/AppTests")
    ]
)
