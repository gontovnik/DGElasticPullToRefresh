// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DGElasticPullToRefresh",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DGElasticPullToRefresh",
            targets: ["DGElasticPullToRefresh"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DGElasticPullToRefresh",
            resources: [
                .process("DGElasticPullToRefreshPreview1.gif"),
                .process("DGElasticPullToRefreshPreview2.gif"),
                .copy("settings.plist")
            ]
        )
    ]
)
