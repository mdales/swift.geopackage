// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeoPackage",
    products: [
        .library(
            name: "GeoPackage",
            targets: ["GeoPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        .target(
            name: "GeoPackage",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]),
        .testTarget(
            name: "GeoPackageTests",
            dependencies: ["GeoPackage"],
            resources: [
                .copy("Resources/empty.gpkg"),
                .copy("Resources/simple.gpkg"),
                .copy("Resources/multiple_features.gpkg"),
            ]
        ),
    ]
)
