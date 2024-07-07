// swift-tools-version: 5.9.2

import PackageDescription

let hBird = "https://github.com/hummingbird-project/hummingbird.git"
let async = "https://github.com/swift-server/async-http-client.git"
let tgApi = "https://github.com/nerzh/swift-telegram-sdk"

let package = Package(
    name: "DaradanayaTales",
    platforms: [
        SupportedPlatform.macOS(.v14)
    ],
    products: [.executable(name: "DaradanayaTales", targets: ["DaradanayaTales"])],
    dependencies: [
        .package(url: tgApi, from: "3.1.4"),
        .package(url: hBird, from: "2.0.0-rc.2"),
        .package(url: async, from: "1.21.2")
    ],
    targets: [
        .executableTarget(name: "DaradanayaTales",
              dependencies: [
                    .product(name: "Hummingbird", package: "hummingbird"),
                    .product(name: "AsyncHTTPClient", package: "async-http-client"),
                    .product(name: "SwiftTelegramSdk", package: "swift-telegram-sdk"),
              ],
              path: "Sources/DaradanayaTalesBot",
              exclude: [],
              resources: []),
    ]
)
