// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotarizeProcess",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "NotarizeProcess",
            targets: ["NotarizeProcess"])
    ],
    dependencies: [
        .package(url: "https://github.com/phimage/NotarizationInfo", .revision("HEAD")),
        .package(url: "https://github.com/phimage/NotarizationAuditLog", .revision("HEAD"))
    ],
    targets: [
        .target(
            name: "NotarizeProcess",
            dependencies: ["NotarizationInfo", "NotarizationAuditLog"]),
        .testTarget(
            name: "NotarizeProcessTests",
            dependencies: ["NotarizeProcess"])
    ]
)
