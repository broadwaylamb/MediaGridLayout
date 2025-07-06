// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaGridLayout",
    products: [
        .library(
            name: "MediaGridLayout",
            targets: ["MediaGridLayout"]
        ),
    ],
    targets: [
        .target(name: "MediaGridLayout"),
        .testTarget(
            name: "MediaGridLayoutTests",
            dependencies: ["MediaGridLayout"],
        ),
    ]
)
