import SwiftUI

enum Experiment: String, CaseIterable, Identifiable, Hashable {
    case sizeClass = "01"
    case breakpoints = "01b"
    case player = "02"
    case popup = "03"
    case hinge = "04"
    case resize = "05"
    case safeArea = "07"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sizeClass: "01 Size class"
        case .breakpoints: "01-b Breakpoints vs size class"
        case .player: "02 Player arrangement"
        case .popup: "03 Custom popup"
        case .hinge: "04 Hinge"
        case .resize: "05 Resize (PiP / portrait-only)"
        case .safeArea: "07 Safe area"
        }
    }

    var subtitle: String {
        switch self {
        case .sizeClass: "Structure by size class, content fluid"
        case .breakpoints: "A: size class · B: 3 width tiers · C: hybrid"
        case .player: "ArrangementView overlay / split / manual"
        case .popup: "System presentations vs custom overlay vs hinge-aware"
        case .hinge: "onHingeChange angle, status, effects"
        case .resize: "Fixed-height layout under vertical resizing"
        case .safeArea: "Full-bleed background, insets, reserved regions"
        }
    }

    @MainActor @ViewBuilder
    var destination: some View {
        switch self {
        case .sizeClass: SizeClassExperiment()
        case .breakpoints: BreakpointExperiment()
        case .player: PlayerArrangementExperiment()
        case .popup: CustomPopupExperiment()
        case .hinge: HingeExperiment()
        case .resize: ResizeExperiment()
        case .safeArea: SafeAreaExperiment()
        }
    }
}

/// Deep links for the capture tool:
///   duolab://experiment/<id>[?variant=<name>&overlay=0|1]
/// The capture script passes the link as a launch argument (`-openURL <url>`) instead of
/// `simctl openurl`, which shows an "Open in …?" confirmation when two apps share a scheme.
/// Launch argument `-debugOverlay NO` hides the overlay by default.
@MainActor @Observable
final class Router {
    var path: [Experiment] = []
    var variant: String?
    var showsOverlay: Bool = UserDefaults.standard.object(forKey: "debugOverlay") as? Bool ?? true

    init() {
        if let link = UserDefaults.standard.string(forKey: "openURL"), let url = URL(string: link) {
            open(url)
        }
    }

    func open(_ url: URL) {
        guard url.scheme?.hasPrefix("duolab") == true, url.host() == "experiment",
              let id = url.pathComponents.dropFirst().first,
              let experiment = Experiment(rawValue: id) else { return }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        variant = items.first { $0.name == "variant" }?.value
        if let overlay = items.first(where: { $0.name == "overlay" })?.value {
            showsOverlay = overlay == "1"
        }
        path = [experiment]
    }
}
