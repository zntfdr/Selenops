// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "selenops",
    dependencies: [
      .package(url: "https://github.com/apple/swift-tools-support-core.git",
               from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "selenopsCLI",
            dependencies: ["selenopsCore", "SwiftToolsSupport"]),
        .target(name: "selenopsCore"),
        .testTarget(
            name: "selenopsTests",
            dependencies: ["selenopsCLI"]),
    ]
)
