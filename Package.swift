// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let target = Target.target(
    name: "SwiftyCrypto",
    dependencies: [],
    path: "Sources")


private let testTarget = Target.testTarget(
    name: "SwiftyCryptoTests",
    dependencies: ["SwiftyCrypto"],
    path: "SwiftyCryptoTests",
    exclude: [
        "Info.plist",
        "RSA/private.txt",
        "RSA/private.pem",
        "RSA/public.txt",
        "RSA/public.pem",
        "RSA/RSAKeySigningTests.swift"
    ],
    sources: [
        "HMAC-Based/HMACTests.swift",
        "RSA/RSAMessageTests.swift"
    ])

let package = Package(
    name: "SwiftyCrypto",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        .library(
            name: "SwiftyCrypto",
            targets: ["SwiftyCrypto"]),
    ],
    dependencies: [
    ],
    targets: [target, testTarget]
)
