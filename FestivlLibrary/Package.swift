// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivlLibrary",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FestivlLibrary", targets: ["FestivlLibrary"]),
        .library(name: "FestivlAppFeature", targets: ["FestivlAppFeature"]),
        .library(name: "EventFeature", targets: ["EventFeature"]),
        .library(name: "TabBarFeature", targets: ["TabBarFeature"]),
        .library(name: "ArtistListFeature", targets: ["ArtistListFeature"]),
        .library(name: "ArtistPageFeature", targets: ["ArtistPageFeature"]),
        .library(name: "ServiceCore", targets: ["ServiceCore"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "Components", targets: ["Components"]),
        .library(name: "EventListFeature", targets: ["EventListFeature"]),
        .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
        .library(name: "ExploreFeature", targets: ["ExploreFeature"]),

        // MARK: FestivlManager
        .library(name: "FestivlManagerAppFeature", targets: ["FestivlManagerAppFeature"]),
        .library(name: "FestivlManagerEventFeature", targets: ["FestivlManagerEventFeature"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.0"),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0"),
        .package(url: "https://github.com/lorenzofiamingo/SwiftUI-CachedAsyncImage", from: "1.0.0"),
        .package(url: "https://github.com/yacir/CollectionViewSlantedLayout", branch: "master")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlLibrary",
            dependencies: []
        ),
        .target(
            name: "FestivlAppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "EventListFeature"),
                .target(name: "Models"),
                .target(name: "EventFeature")
            ]
        ),
        .target(
            name: "EventFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "TabBarFeature"),
                .target(name: "Models"),
                .target(name: "Services")
            ]
        ),
        .target(name: "Models", dependencies: [
            .target(name: "Utilities"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase"),
        ]),
        .target(name: "Utilities", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "Components", dependencies: [
            .target(name: "Models")
        ]),
        .target(name: "ServiceCore", dependencies: [
            .target(name: "Utilities"),
            .product(name: "FirebaseFirestore", package: "Firebase"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase")
        ]),
        .target(name: "Services", dependencies: [
            .target(name: "Models"),
            .target(name: "ServiceCore"),
            .product(name: "FirebaseFirestore", package: "Firebase"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase")
        ]),
        .target(
            name: "TabBarFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "ArtistListFeature"),
                .target(name: "ScheduleFeature"),
                .target(name: "Models"),
                .target(name: "Utilities")
            ]
        ),
        .target(
            name: "ArtistListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "ArtistPageFeature"),
                .target(name: "Models"),
                .target(name: "Utilities"),
                .target(name: "Services"),
                .target(name: "Components")
            ]
        ),
        .target(
            name: "ArtistPageFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "Models"),
                .target(name: "Utilities"),
                .target(name: "Components")
            ],
            resources: [
                .copy("LinkIcons.xcassets")
            ]
        ),
        .target(
            name: "EventListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CachedAsyncImage", package: "SwiftUI-CachedAsyncImage"),
                .target(name: "Models"),
                .target(name: "Utilities"),
                .target(name: "Services"),
            ]
        ),
        .target(
            name: "ScheduleFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "Models"),
                .target(name: "Utilities"),
                .target(name: "Components")
            ]

        ),
        .target(
            name: "ExploreFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CollectionViewSlantedLayout", package: "CollectionViewSlantedLayout"),
                .target(name: "Models"),
                .target(name: "Utilities")
            ]
        ),

        // MARK: FestivlManager
        .target(
            name: "FestivlManagerAppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "EventListFeature")
            ]
        ),
        .target(
            name: "FestivlManagerEventFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "Models")
            ]
        ),

        // MARK: Tests
        .testTarget(name: "FestivlLibraryTests", dependencies: ["FestivlLibrary"]),
        .testTarget(name: "ComponentTests", dependencies: ["Components"]),
        .testTarget(name: "SlantedListTests", dependencies: ["ExploreFeature"])
    ]
)
