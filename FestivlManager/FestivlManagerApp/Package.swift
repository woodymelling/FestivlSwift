// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let composableArchitecture = product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    
    static let models = library(name: "Models")
    static let utlities = library(name: "Utilities")
    static let festivlDependencies = library(name: "FestivlDependencies")
    static let sharedResources = library(name: "SharedResources")
    static let components = library(name: "Components")
    
    static let forms = product(name: "ComposableArchitectureForms", package: "composable-architecture-forms")
    
    static func library(name: String) -> Self {
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
        ),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
        .library(name: "CriteriaUI", targets: ["CriteriaUI"])

    ],
    dependencies: [
        .package(name: "FestivlLibrary", path: "../FestivlLibrary"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/woodymelling/composable-architecture-forms", branch: "main"),
        .package(url: "https://github.com/WilhelmOks/ArrayBuilder.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FestivlManagerApp",
            dependencies: [
                .composableArchitecture,
                .utlities,
                .models,
                .festivlDependencies,
                .sharedResources,
                .forms,
                "OnboardingFeature"
            ]
        ),

        .target(
            name: "ScheduleManagementFeature",
            dependencies: [
                .composableArchitecture,
                .utlities,
                .models,
                .library(name: "ScheduleComponents"),
                .festivlDependencies,
            ]
        ),
        
        .target(
            name: "OnboardingFeature",
            dependencies: [
                .composableArchitecture,
                .utlities,
                .models,
                .festivlDependencies,
                .sharedResources,
                .components,
                .library(name: "TimeZonePicker"),
                .library(name: "ComposablePhotosPicker"),
                .forms,
                "CriteriaUI"
            ]
        ),
        .target(
            name: "CriteriaUI",
            dependencies: [
                .utlities,
                .product(name: "ArrayBuilderModule", package: "arraybuilder")
            ]
        ),
        .testTarget(
            name: "ScheduleManagementTests",
            dependencies: ["ScheduleManagementFeature"]
        ),
        .testTarget(
            name: "FestivlManagerAppTests",
            dependencies: ["FestivlManagerApp", .festivlDependencies]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["OnboardingFeature", .festivlDependencies]
        )
    ]
)
