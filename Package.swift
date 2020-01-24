// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Datasets",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "Datasets",
            targets: ["Datasets"])
    ],
    dependencies: [
        .package(url: "https://github.com/s5tf-team/S5TF/", .branch("master"))
    ],
    targets: [
        .target(
            name: "Datasets",
            dependencies: ["S5TF"]),
        .testTarget(
            name: "DatasetsTests",
            dependencies: ["Datasets"])
    ]
)
