// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReihumCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ReihumCore", targets: ["ReihumCore"])
    ],
    targets: [
        .target(name: "ReihumCore"),
        .testTarget(name: "ReihumCoreTests", dependencies: ["ReihumCore"])
    ]
)
