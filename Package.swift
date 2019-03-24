// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StrongSelfRewriter",
    products: [
        .executable(name:"StrongSelfRewriter", targets: ["StrongSelfRewriter"]),
        .library(name: "StrongSelfRewriterCore", targets: ["StrongSelfRewriterCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "0.40200.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", .branch("swift-4.2-branch"))
    ],
    targets: [
        .target(
            name: "StrongSelfRewriter",
            dependencies: [
                "StrongSelfRewriterCore"
            ]),
        .target(
            name: "StrongSelfRewriterCore",
            dependencies: [
                "SwiftSyntax",
                "Utility"
            ]),
        .testTarget(
            name: "StrongSelfRewriterTests",
            dependencies: ["StrongSelfRewriter"]),
    ]
)
