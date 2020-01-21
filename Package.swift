// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Datasets",
    products: [
        .library(
            name: "Datasets",
            targets: ["Datasets"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tensorflow/swift-apis/", .branch("tensorflow-0.6")),
    ],
    targets: [
        .target(
            name: "Datasets",
            dependencies: []),
        .testTarget(
            name: "DatasetsTests",
            dependencies: ["Datasets"]),
    ]
)
