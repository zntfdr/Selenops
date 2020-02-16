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
        .package(url: "https://github.com/apple/swift-tools-support-core.git",
                 from: "0.0.1")
    ],
    targets: [
        .target(name: "Selenops"),
        .target(
            name: "selenopsCLI",
            dependencies: ["Selenops", "SwiftToolsSupport"]),
        .testTarget(
            name: "selenopsTests",
            dependencies: ["selenopsCLI"])
    ]
)
