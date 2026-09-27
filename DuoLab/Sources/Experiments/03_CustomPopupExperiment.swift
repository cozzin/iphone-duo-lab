import SwiftUI

/// Experiment 03: system presentations vs naive custom overlay vs hinge-aware custom overlay.
struct CustomPopupExperiment: View {
    enum Kind: String { case alert, sheet, popover, naive, hingeAware }

    @Environment(Router.self) private var router
    @State private var presented: Kind?
    @State private var trigger: CGRect?

    var body: some View {
        switch router.variant {
        case "arrEmpty", "arrClear", "arrAlert":
            ArrangementAlertHost(variant: router.variant ?? "")
        default:
            standard
        }
    }

    private var standard: some View {
        HStack {
            buttons.frame(maxWidth: .infinity)
            buttons.frame(maxWidth: .infinity)   // same buttons on both sides to test "stay contextual"
        }
        .frame(maxHeight: .infinity)
        .coordinateSpace(.named("popupSpace"))
        .navigationTitle("03 Custom popup")
        .task {
            // Capture tool: duolab://experiment/03?variant=<kind> presents it without a tap.
            // No trigger frame → the hinge-aware rule falls back to the trailing/bottom region.
            if let kind = router.variant.flatMap(Kind.init(rawValue:)), kind != .popover {
                try? await Task.sleep(for: .milliseconds(600))
                presented = kind
            }
        }
        .alert("System alert", isPresented: binding(.alert)) { Button("OK") {} }
        .sheet(isPresented: binding(.sheet)) {
            Text("System sheet").presentationDetents([.medium])
        }
        .overlay {
            if presented == .naive {
                PopupCard(title: "Naive custom popup") { presented = nil }
            }
        }
        .modifier(HingeAwareOverlay(isPresented: presented == .hingeAware, triggerFrame: trigger) {
            PopupCard(title: "Hinge-aware popup") { presented = nil }
        })
    }

    private var buttons: some View {
        VStack(spacing: 16) {
            button("Alert", .alert)
            button("Sheet", .sheet)
            PopoverButton()
            button("Custom (naive)", .naive)
            button("Custom (hinge-aware)", .hingeAware)
        }
        .buttonStyle(.bordered)
    }

    private func button(_ title: String, _ kind: Kind) -> some View {
        GeometryReader { proxy in
            Button(title) {
                trigger = proxy.frame(in: .named("popupSpace"))
                presented = kind
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 44)
    }

    private func binding(_ kind: Kind) -> Binding<Bool> {
        Binding { presented == kind } set: { if !$0 { presented = nil } }
    }
}

/// Idea under test: host the screen as the *secondary* of an overlay ArrangementView and put a custom
/// alert in the *primary*. When folded, the overlay arrangement moves the primary to the trailing/bottom
/// region by itself. Question: when no alert is shown, does an empty primary still take half the screen?
///   arrEmpty → primary = EmptyView, arrClear → primary = Color.clear, arrAlert → primary = alert card
struct ArrangementAlertHost: View {
    var variant: String

    var body: some View {
        ArrangementView {
            primary
                .measured("primary")
        } secondary: {
            ScreenContent()
                .measured("secondary")
        }
        .arrangementViewStyle(.overlay)
        .navigationTitle("03 \(variant)")
    }

    @ViewBuilder private var primary: some View {
        switch variant {
        case "arrClear": Color.clear
        case "arrAlert": PopupCard(title: "Custom alert in primary") {}
        default: EmptyView()
        }
    }
}

/// Stand-in for an ordinary screen: scrolling content plus a fixed button.
private struct ScreenContent: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(0..<20) { SampleCard(index: $0) }
                }
                .padding()
            }
            Button("Fixed action") {}.buttonStyle(.borderedProminent).padding()
        }
        .border(.cyan, width: 3)
    }
}

extension View {
    /// Logs and outlines this view's global frame (debug only).
    func measured(_ name: String) -> some View {
        border(.pink, width: 2)
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                duoLog.notice("FRAME \(name, privacy: .public)=\(String(describing: $0), privacy: .public)")
            }
    }
}

private struct PopoverButton: View {
    @State private var shown = false
    var body: some View {
        Button("Popover") { shown = true }
            .popover(isPresented: $shown) { Text("System popover").padding() }
    }
}

struct PopupCard: View {
    var title: String
    var dismiss: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Text("A custom overlay used for confirmations or promos.").font(.subheadline).multilineTextAlignment(.center)
            Button("Close", action: dismiss).buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .shadow(radius: 20)
    }
}

/// Places the popup inside one sub-region created by an active division (the fold).
/// Rule (docs/research/03-custom-popup.md): region containing the trigger → otherwise trailing/bottom.
struct HingeAwareOverlay<Popup: View>: ViewModifier {
    var isPresented: Bool
    var triggerFrame: CGRect?
    @ViewBuilder var popup: () -> Popup

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                GeometryReader { proxy in
                    let bounds = CGRect(origin: .zero, size: proxy.size)
                    let divisions = proxy.reservedRegions(kind: .division).filter(\.isActive).map(\.frame)
                    let target = HingeLayout.targetRegion(in: bounds, divisions: divisions, trigger: triggerFrame)
                    popup()
                        .frame(maxWidth: max(target.width - 32, 0), maxHeight: max(target.height - 32, 0))
                        .position(x: target.midX, y: target.midY)
                }
            }
        }
    }
}

enum HingeLayout {
    static func targetRegion(in bounds: CGRect, divisions: [CGRect], trigger: CGRect?) -> CGRect {
        guard let d = divisions.first else { return bounds }
        let vertical = d.height >= d.width
        let first: CGRect
        let second: CGRect
        if vertical {
            first = CGRect(x: bounds.minX, y: bounds.minY, width: d.minX - bounds.minX, height: bounds.height)
            second = CGRect(x: d.maxX, y: bounds.minY, width: bounds.maxX - d.maxX, height: bounds.height)
        } else {
            first = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: d.minY - bounds.minY)
            second = CGRect(x: bounds.minX, y: d.maxY, width: bounds.width, height: bounds.maxY - d.maxY)
        }
        if let t = trigger {
            let center = CGPoint(x: t.midX, y: t.midY)
            if first.contains(center) { return first }
            if second.contains(center) { return second }
        }
        return second
    }
}
