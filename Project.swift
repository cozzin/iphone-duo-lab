import ProjectDescription

// Shared Info.plist keys for both app targets.
// `orientations` differs so experiment 05 can compare a portrait-only build against a fully rotatable one.
func infoPlist(orientations: [String]) -> InfoPlist {
    .extendingDefault(with: [
        "UILaunchScreen": [:],
        "UIApplicationSceneManifest": ["UIApplicationSupportsMultipleScenes": true],
        "UISupportedInterfaceOrientations": .array(orientations.map { .string($0) }),
        "CFBundleURLTypes": [
            ["CFBundleURLName": "dev.duolab", "CFBundleURLSchemes": ["duolab"]],
        ],
    ])
}

let allOrientations = [
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
    "UIInterfaceOrientationPortraitUpsideDown",
]

let project = Project(
    name: "DuoLab",
    targets: [
        .target(
            name: "DuoLab",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "dev.duolab.app",
            deploymentTargets: .iOS("27.1"),
            infoPlist: infoPlist(orientations: allOrientations),
            sources: ["DuoLab/Sources/**"]
        ),
        // Same sources, portrait only (experiment 05).
        .target(
            name: "DuoLabPortraitOnly",
            destinations: [.iPhone],
            product: .app,
            bundleId: "dev.duolab.portraitonly",
            deploymentTargets: .iOS("27.1"),
            infoPlist: infoPlist(orientations: ["UIInterfaceOrientationPortrait"]),
            sources: ["DuoLab/Sources/**"]
        ),
    ]
)
