import ProjectDescription

let project = Project(
    name: "Framework1",
    targets: [
        .target(
            name: "Framework1",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Framework1",
            infoPlist: "Config/Framework1-Info.plist",
            sources: "Sources/**",
            dependencies: [
                .project(target: "Framework2", path: "../Framework2"),
            ]
        ),

        .target(
            name: "Framework1Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Framework1Tests",
            infoPlist: "Config/Framework1Tests-Info.plist",
            sources: "Tests/**",
            dependencies: [
                .target(name: "Framework1"),
            ]
        ),
    ]
)
