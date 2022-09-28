// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivlLibrary",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FestivlLibrary", targets: ["FestivlLibrary"]),
        .library(name: "ServiceCore", targets: ["ServiceCore"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "Components", targets: ["Components"]),
        .library(name: "SharedResources", targets: ["SharedResources"]),
        .library(name: "FestivlDependencies", targets: ["FestivlDependencies"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "protocol-beta"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.2.0"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlLibrary",
            dependencies: []
        ),
        .target(name: "Models", dependencies: [
            .target(name: "Utilities"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
        ]),
        .target(name: "Utilities", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "Kingfisher", package: "Kingfisher")

        ]),
        .target(name: "Components", dependencies: [
            .target(name: "Models")
        ]),
        .target(name: "ServiceCore", dependencies: [
            .target(name: "Utilities"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk")
        ]),
        .target(name: "Services", dependencies: [
            .target(name: "Models"),
            .target(name: "ServiceCore"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorageSwift-Beta", package: "firebase-ios-sdk")
        ]),
        .target(
            name: "SharedResources",
            dependencies: [],
            resources: [
                .copy("LinkIcons.xcassets")
            ]
        ),
        .target(
            name: "FestivlDependencies",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        

        // MARK: Tests
        .testTarget(name: "FestivlLibraryTests", dependencies: ["FestivlLibrary"]),
        .testTarget(name: "ComponentTests", dependencies: ["Components"]),
    ]
)
