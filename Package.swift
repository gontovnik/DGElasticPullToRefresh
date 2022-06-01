// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DGElasticPullToRefresh",
    products: [
        .library(
            name: "DGElasticPullToRefresh",
            targets: ["DGElasticPullToRefresh"]),
    ],
    targets: [
        .target(
            name: "DGElasticPullToRefresh"),
    ]
)
