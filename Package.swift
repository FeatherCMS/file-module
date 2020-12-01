// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "file-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "FileModule", targets: ["FileModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/binarybirds/feather-core", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "FileModule", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
        ],
        resources: [
            .copy("Bundle"),
        ]),
        .testTarget(name: "FileModuleTests", dependencies: [
            .target(name: "FileModule"),
        ])
    ]
)
