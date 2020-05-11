// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "scrap-server",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/mannberg/IsValid.git", from: "1.0.2"),
        .package(url: "https://github.com/mannberg/scrap-data-models", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "IsValid", package: "IsValid"),
            .product(name: "scrap-data-models", package: "scrap-data-models")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
