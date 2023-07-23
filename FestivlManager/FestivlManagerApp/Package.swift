// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let composableArchitecture = product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    
    static let models = library(name: "Models")
    static let utlities = library(name: "Utilities")
    static let festivlDependencies = library(name: "FestivlDependencies")
    
    static func library(name: String) -> Target.Dependency {
        product(name: name, package: "FestivlLibrary")
    }
}

let package = Package(
    name: "FestivlManagerApp",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FestivlManagerApp",
            targets: ["FestivlManagerApp"]
        ),
        .library(
            name: "ScheduleManagementFeature",
            targets: ["ScheduleManagementFeature"]
        )
    ],
    dependencies: [
        .package(name: "FestivlLibrary", path: "../FestivlLibrary"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "prerelease/1.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FestivlManagerApp"
        ),
        .target(
            name: "ScheduleManagementFeature",
            dependencies: [
                .composableArchitecture,
                .utlities,
                .models,
                .library(name: "ScheduleComponents"),
                .festivlDependencies
            ]
        ),
        .testTarget(
            name: "FestivlManagerAppTests",
            dependencies: ["FestivlManagerApp"]
        ),
        .testTarget(
            name: "ScheduleManagementTests",
            dependencies: ["ScheduleManagementFeature"]
        )
    ]
)
