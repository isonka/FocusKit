// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FocusKit", targets: ["FocusKit"]),
        .library(name: "FocusKitBlocking", targets: ["FocusKitBlocking"]),
    ],
    targets: [
        .target(
            name: "FocusKit",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "FocusKitBlocking",
            dependencies: ["FocusKit"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "FocusKitTests",
            dependencies: ["FocusKit"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
