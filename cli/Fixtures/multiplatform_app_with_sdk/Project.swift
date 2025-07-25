import ProjectDescription

let project = Project(
    name: "Project",
    targets: [
        .target(
            name: "MyTestFramework",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.MyTestFramework",
            infoPlist: .default,
            sources: "MyTestFramework/**",
            dependencies: [
                .xctest,
            ]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.AppTests",
            infoPlist: "Support/Tests.plist",
            sources: "Tests/**",
            dependencies: [
                .target(name: "App"),
                .target(name: "MyTestFramework"),
            ]
        ),
        .target(
            name: "App",
            destinations: [.iPhone, .iPad, .mac],
            product: .app,
            bundleId: "dev.tuist.App",
            infoPlist: "Support/App-Info.plist",
            sources: "App/**",
            dependencies: [
                .sdk(name: "CloudKit", type: .framework, status: .required),
                .sdk(name: "ARKit", type: .framework, status: .required, condition: .when([.ios])),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebasePerformance", condition: .when([.ios])),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "FirebaseInAppMessaging-Beta"),
                .sdk(name: "MobileCoreServices", type: .framework, status: .required, condition: .when([.ios])),
            ]
        ),
        .target(
            name: "MultiPlatformFramework",
            destinations: [.iPad, .iPhone, .mac, .appleTv],
            product: .framework,
            bundleId: "dev.tuist.MacFramework",
            infoPlist: "Support/Framework-Info.plist",
            sources: [
                .glob("Framework/Shared/**"),
                .glob("Framework/tvOS/**", compilationCondition: .when([.tvos])),
                .glob("Framework/macOS/**", compilationCondition: .when([.macos])),
                .glob("Framework/iOS/**", compilationCondition: .when([.ios])),
            ],
            dependencies: [
                .sdk(name: "CloudKit", type: .framework, status: .optional),
                .sdk(name: "sqlite3", type: .library),
            ]
        ),
    ]
)
