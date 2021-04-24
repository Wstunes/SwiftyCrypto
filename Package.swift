// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCrypto",
    platforms: [
        .iOS(.v11), .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftyCrypto",
            targets: ["SwiftyCrypto"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SwiftyCrypto",
                path: "Sources",
                exclude: ["CCommonCrypto"])
    ]
)
