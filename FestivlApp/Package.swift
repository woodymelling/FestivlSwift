// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let composableArchitecture = product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    
    static let models = product(name: "Models", package: "FestivlLibrary")
    static let utlities = product(name: "Utilities", package: "FestivlLibrary")
    static let festivlDependencies = product(name: "FestivlDependencies", package: "FestivlLibrary")
}

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
        .library(name: "iOSComponents", targets: ["iOSComponents"]),
        .library(name: "MoreFeature", targets: ["MoreFeature"]),
        .library(name: "NotificationsFeature", targets: ["NotificationsFeature"]),
        .library(name: "ShowScheduleItemDependency", targets: ["ShowScheduleItemDependency"]),
        .library(name: "WorkshopsFeature", targets: ["WorkshopsFeature"]),
        .library(name: "ScheduleComponents", targets: ["ScheduleComponents"])
    ],
    dependencies: [
        .package(name: "FestivlLibrary", path: "../../FestivlLibrary"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "prerelease/1.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
        
        .package(url: "https://github.com/miiha/composable-user-notifications", from: "0.5.0"),
        
        .package(url: "https://github.com/yacir/CollectionViewSlantedLayout", branch: "master"),
        .package(url: "https://github.com/Jake-Short/swiftui-image-viewer.git", from: "2.3.1"),
        .package(url: "https://github.com/elai950/AlertToast", branch: "master"),
        .package(url: "https://github.com/aheze/Popovers", from: "1.3.2"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FestivlAppFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                
                "EventListFeature",
                "EventFeature",
                
                .product(name: "FirebaseServiceImpl", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "EventListFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                .festivlDependencies,
                
                .product(name: "Components", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "EventFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .festivlDependencies,
                
                "ArtistListFeature",
                "ScheduleFeature",
                "ExploreFeature",
                "MoreFeature",
                
                "ScheduleComponents",
                
                "ShowScheduleItemDependency",
                
                .product(name: "ComposableUserNotifications", package: "composable-user-notifications")
            ]
        ),
        .target(
            name: "ArtistListFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                .festivlDependencies,
                
                "ArtistPageFeature",
                "iOSComponents",
                
                .product(name: "Components", package: "FestivlLibrary"),
            ]
        ),
        .target(
            name: "ArtistPageFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                
                "ShowScheduleItemDependency",
                
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "SharedResources", package: "FestivlLibrary"),
                .product(name: "FestivlDependencies", package: "FestivlLibrary"),
                
            ]
        ),

        .target(
            name: "ScheduleFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                
                "ArtistPageFeature",
                "GroupSetDetailFeature",
                "ScheduleComponents",
                
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "Popovers", package: "Popovers"),
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "ComposableArchitectureUtilities", package: "FestivlLibrary")
            ]

        ),
        .target(
            name: "ExploreFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                
                "ArtistPageFeature",
                
                .product(name: "CollectionViewSlantedLayout", package: "CollectionViewSlantedLayout")
            ]
        ),
        .target(
            name: "GroupSetDetailFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                
                "ArtistPageFeature",
                "iOSComponents",
                "ShowScheduleItemDependency",
                
                .product(name: "Components", package: "FestivlLibrary")
            ]
        ),
        .target(
            name: "iOSComponents",
            dependencies: [
                .composableArchitecture,
                .models,
                .utlities,
                
                .product(name: "Components", package: "FestivlLibrary"),
                .product(name: "Collections", package: "swift-collections")
           ]
        ),
        .target(
            name: "MoreFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                .festivlDependencies,
                
                .product(name: "Components", package: "FestivlLibrary"),
                
                .product(name: "ImageViewer", package: "swiftui-image-viewer"),
                .target(name: "NotificationsFeature")
            ],
            resources: [
                .copy("Media.xcassets")
            ]
        ),
        .target(
            name: "NotificationsFeature",
            dependencies: [
                .composableArchitecture,
                .models,
                
                .product(name: "FestivlDependencies", package: "FestivlLibrary")
            ]
        ),
        
        .target(
            name: "ShowScheduleItemDependency",
            dependencies: [
                .models,
                
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        
        .target(
            name: "WorkshopsFeature",
            dependencies: [
                .models,
                .composableArchitecture,
                .festivlDependencies,
                .utlities,
                
                "ScheduleComponents",
            ]
        ),
        
        .target(
            name: "ScheduleComponents",
            dependencies: [
                .utlities,
            ]
        )
    ]
)
