// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BSTextTest",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(path: "/Users/hongboliu/Documents/projects/BSText")
    ],
    targets: [
        .executableTarget(
            name: "BSTextTest",
            dependencies: ["BSText"],
            path: "Sources",
            info: .init(path: "Sources/BSTextTest/Info.plist"))
    ]
)
