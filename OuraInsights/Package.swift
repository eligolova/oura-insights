// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OuraInsights",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OuraInsights",
            targets: ["OuraInsights"]
        )
    ],
    targets: [
        .target(
            name: "OuraInsights",
            dependencies: [],
            path: "."
        ),
        .testTarget(
            name: "OuraInsightsTests",
            dependencies: ["OuraInsights"],
            path: "../OuraInsightsTests"
        )
    ]
)
