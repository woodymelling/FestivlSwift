// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivlApp",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FestivlAppFeature", targets: ["FestivlAppFeature"]),
        .library(name: "EventFeature", targets: ["EventFeature"]),
        .library(name: "ArtistListFeature", targets: ["ArtistListFeature"]),
        .library(name: "ArtistPageFeature", targets: ["ArtistPageFeature"]),
        .library(name: "EventListFeature", targets: ["EventListFeature"]),
        .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
        .library(name: "ExploreFeature", targets: ["ExploreFeature"]),
        .library(name: "GroupSetDetailFeature", targets: ["GroupSetDetailFeature"]),
        .library(name: "iOSComponents", targets: ["iOSComponents"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.0"),
        .package(url: "https://github.com/yacir/CollectionViewSlantedLayout", branch: "master"),
        .package(name: "FestivlLibrary", path: "../FestivlLibrary"),
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.0.0"),
        .package(url: "https://github.com/stonko1994/SimultaneouslyScrollView", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlAppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "EventListFeature"),
                .product(name: "Models", package: "FestivlLibrary"),
                .target(name: "EventFeature"),
            ]
        ),
        .target(
            name: "EventListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "EventFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "ArtistListFeature"),
                .target(name: "ScheduleFeature"),
                .target(name: "ExploreFeature"),
            ]
        ),
        .target(
            name: "ArtistListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "ArtistPageFeature"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .target(name: "iOSComponents"),
            ]
        ),
        .target(
            name: "ArtistPageFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "SharedResources", package: "FestivlLibrary")
            ]
        ),

        .target(
            name: "ScheduleFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "Introspect", package: "Introspect"),
                .product(name: "SimultaneouslyScrollView", package: "SimultaneouslyScrollView"),
                .target(name: "ArtistPageFeature"),
                .target(name: "GroupSetDetailFeature")
            ]

        ),
        .target(
            name: "ExploreFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CollectionViewSlantedLayout", package: "CollectionViewSlantedLayout"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .target(name: "ArtistPageFeature")
            ]
        ),
        .target(
            name: "GroupSetDetailFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .target(name: "ArtistPageFeature"),
                .target(name: "iOSComponents")
            ]
        ),
        .target(
            name: "iOSComponents",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
           ]
        )
    ]
)
