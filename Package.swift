// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPClient",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HTTPClient",
            dependencies: []),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient"]),
    ],
    swiftLanguageVersions: [
        .version("5.2")
    ]
)
