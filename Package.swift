// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ResearchSupervisionLog",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ResearchSupervisionLog",
            dependencies: [],
            path: "Sources"
        )
    ]
)
