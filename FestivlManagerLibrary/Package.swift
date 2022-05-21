// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FestivlManagerLibrary",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FestivlManagerAppFeature", targets: ["FestivlManagerAppFeature"]),
        .library(name: "FestivlManagerEventFeature", targets: ["FestivlManagerEventFeature"]),
        .library(name: "ManagerEventListFeature", targets: ["ManagerEventListFeature"]),
        .library(name: "ManagerArtistsFeature", targets: ["ManagerArtistsFeature"]),
        .library(name: "MacOSComponents", targets: ["MacOSComponents"]),
        .library(name: "CreateArtistFeature", targets: ["CreateArtistFeature"]),
        .library(name: "ManagerArtistDetailFeature", targets: ["ManagerArtistDetailFeature"]),
        .library(name: "StagesFeature", targets: ["StagesFeature"]),
        .library(name: "AddEditStageFeature", targets: ["AddEditStageFeature"]),
        .library(name: "StageDetailFeature", targets: ["StageDetailFeature"]),
        .library(name: "ManagerScheduleFeature", targets: ["ManagerScheduleFeature"]),
        .library(name: "AddEditArtistSetFeature", targets: ["AddEditArtistSetFeature"]),
        .library(name: "AddEditEventFeature", targets: ["AddEditEventFeature"]),
        .library(name: "AddEditGroupSetFeature", targets: ["AddEditGroupSetFeature"]),
        .library(name: "EventDataFeature", targets: ["EventDataFeature"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.0"),
        .package(name: "FestivlLibrary", path: "../FestivlLibrary")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlManagerAppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .target(name: "FestivlManagerEventFeature"),
                .target(name: "ManagerEventListFeature")
            ]
        ),
        .target(
            name: "ManagerEventListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "AddEditEventFeature")
            ]
        ),
        .target(
            name: "FestivlManagerEventFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "ManagerArtistsFeature"),
                .target(name: "StagesFeature"),
                .target(name: "ManagerScheduleFeature"),
                .target(name: "AddEditEventFeature"),
                .target(name: "EventDataFeature"),
            ]
        ),
        .target(
            name: "ManagerArtistsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .target(name: "CreateArtistFeature"),
                .target(name: "ManagerArtistDetailFeature")
            ]
        ),
        .target(
            name: "MacOSComponents",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Utilities", package: "FestivlLibrary"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "CreateArtistFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .target(name: "MacOSComponents"),
                .product(name: "Services", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "ManagerArtistDetailFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .target(name: "MacOSComponents"),
                .product(name: "Services", package: "FestivlLibrary"),
                .product(name: "SharedResources", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "StagesFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "AddEditStageFeature"),
                .target(name: "StageDetailFeature")
            ]
        ),
        .target(
            name: "AddEditStageFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "MacOSComponents")
            ]
        ),
        .target(
            name: "StageDetailFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
            ]
        ),
        .target(
            name: "ManagerScheduleFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .product(name: "ServiceCore", package: "FestivlLibrary"),
                .target(name: "MacOSComponents"),
                .target(name: "AddEditArtistSetFeature")
            ]
        ),
        .target(
            name: "AddEditArtistSetFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "MacOSComponents")
            ]
        ),
        .target(
            name: "AddEditEventFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "MacOSComponents")
            ]
        ),
        .target(
            name: "AddEditGroupSetFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .product(name: "Services", package: "FestivlLibrary"),
                .target(name: "MacOSComponents")
            ]
        ),
        .target(
            name: "EventDataFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Models", package: "FestivlLibrary"),
                .target(name: "MacOSComponents"),
                .product(name: "Services", package: "FestivlLibrary")
            ]
        ),

        
    ]
)
