// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebugView",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "DebugView", targets: ["DebugView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dankinsoid/VDCodable.git", from: "2.11.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint.git", from: "1.4.0"),
        .package(url: "https://github.com/BinaryBirds/swift-http.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "DebugView",
            dependencies: [
                "SwiftPrettyPrint",
                "VDCodable",
                .product(name: "SwiftHttp", package: "swift-http")
            ]
        )
    ]
)
