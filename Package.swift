// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BSText",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BSText",
            targets: ["BSText"])
    ],
    dependencies: [
        .package(url: "https://github.com/ibireme/YYImage.git", from: "1.0.4")
    ],
    targets: [
        .target(
            name: "BSText",
            path: "BSText",
            sources: [
                ".",
                "Component",
                "String",
                "Utility",
                "SwiftUI"
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedFramework("CoreText"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("UIKit")
            ]),
        .testTarget(
            name: "BSTextTests",
            dependencies: ["BSText"],
            path: "Framework/BSTextTests")
    ]
)