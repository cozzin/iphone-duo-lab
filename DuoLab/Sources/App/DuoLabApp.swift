import SwiftUI

@main
struct DuoLabApp: App {
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .onOpenURL { router.open($0) }
        }
    }
}

/// Experiment list. `NavigationStack` (not `NavigationSplitView`) so that experiments
/// can host an `ArrangementView` without nesting it inside a split view (S3 16:09).
struct RootView: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            List(Experiment.allCases) { experiment in
                NavigationLink(value: experiment) {
                    VStack(alignment: .leading) {
                        Text(experiment.title)
                        Text(experiment.subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("DuoLab")
            .navigationDestination(for: Experiment.self) { $0.destination }
        }
        .debugOverlay(isEnabled: router.showsOverlay)
        .providesActiveDivisions()
    }
}
