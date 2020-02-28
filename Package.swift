// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Selenops",
    products: [
        .library(name: "Selenops", targets: ["Selenops"]),
        .executable(name: "selenops-cli", targets: ["selenopsCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.1")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMinor(from: "0.0.1")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "Selenops",
            dependencies: ["SwiftSoup"]),
        .target(
            name: "selenopsCLI",
            dependencies: ["Selenops", "SwiftToolsSupport"])
    ]
)
