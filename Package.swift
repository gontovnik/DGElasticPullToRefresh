// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PSElasticPullToRefresh",
    products: [
        .library(
            name: "PSElasticPullToRefresh",
            targets: ["PSElasticPullToRefresh"]),
    ],
    targets: [
        .target(
            name: "PSElasticPullToRefresh"),
    ]
)
