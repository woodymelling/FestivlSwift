// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var models: Self = "Models"
}

let package = Package(
    name: "FestivlLibrary",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "Components", targets: ["Components"]),
        .library(name: "SharedResources", targets: ["SharedResources"]),
        .library(name: "FestivlDependencies", targets: ["FestivlDependencies"]),
        .library(name: "FirebaseServiceImpl", targets: ["FirebaseServiceImpl"]),
        .library(name: "ScheduleComponents", targets: ["ScheduleComponents"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
        
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.12.0"),
        
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.9.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Models", dependencies: [
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            .target(name: "Utilities"),
            .product(name: "CustomDump", package: "swift-custom-dump"),
            .product(name: "Collections", package: "swift-collections")
        ]),
        .target(name: "Utilities", dependencies: [
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            .product(name: "CustomDump", package: "swift-custom-dump"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .target(name: "Components", dependencies: [
            .models,
            .target(name: "Utilities"),
            .product(name: "Kingfisher", package: "Kingfisher"),
            .product(name: "Collections", package: "swift-collections")
        ]),
        .target(name: "FirebaseServiceImpl", dependencies: [
            .target(name: "Utilities"),
            .target(name: "FestivlDependencies"),
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk")
        ]),
        .target(
            name: "SharedResources",
            dependencies: [
                "Utilities"
            ],
            resources: [
                .copy("Media.xcassets")
            ]
        ),
        .target(
            name: "FestivlDependencies",
            dependencies: [
                .models,
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "ScheduleComponents",
            dependencies: [
                "Utilities",
                "Components"
            ]
        ),
        // MARK: Tests
        .testTarget(name: "ComponentTests", dependencies: ["Components"])
    ]
)
