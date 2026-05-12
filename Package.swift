// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BSText",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BSText",
            targets: ["BSText"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BSText",
            path: "BSText/Sources")
    ],
    swiftLanguageVersions: [.v5]
)
