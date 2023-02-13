// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivlLibrary",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FestivlLibrary", targets: ["FestivlLibrary"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "Components", targets: ["Components"]),
        .library(name: "SharedResources", targets: ["SharedResources"]),
        .library(name: "FestivlDependencies", targets: ["FestivlDependencies"]),
        .library(name: "ComposableArchitectureUtilities", targets: ["ComposableArchitectureUtilities"]),
        .library(name: "FirebaseServiceImpl", targets: ["FirebaseServiceImpl"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.50.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.8.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.6.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.2.0")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlLibrary",
            dependencies: []
        ),
        .target(name: "Models", dependencies: [
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            .target(name: "Utilities")
        ]),
        .target(name: "Utilities", dependencies: [
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        ]),
        .target(name: "Components", dependencies: [
            .target(name: "Models"),
            .target(name: "Utilities"),
            .product(name: "Kingfisher", package: "Kingfisher")
        ]),
        .target(name: "FirebaseServiceImpl", dependencies: [
            .target(name: "Utilities"),
            .target(name: "FestivlDependencies"),
            .product(name: "Dependencies", package: "swift-composable-architecture"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorageSwift-Beta", package: "firebase-ios-sdk")
        ]),
        .target(
            name: "SharedResources",
            dependencies: [],
            resources: [
                .copy("Media.xcassets")
            ]
        ),
        .target(
            name: "FestivlDependencies",
            dependencies: [
                .target(name: "Models"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .target(
            name: "ComposableArchitectureUtilities",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        

        // MARK: Tests
        .testTarget(name: "FestivlLibraryTests", dependencies: ["FestivlLibrary"]),
        .testTarget(name: "ComponentTests", dependencies: ["Components"])
    ]
)
