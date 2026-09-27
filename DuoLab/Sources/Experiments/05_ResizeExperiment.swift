import SwiftUI

/// Experiment 05: a screen written with "tall iPhone" assumptions, and a fluid version.
/// Run it in both DuoLab and DuoLabPortraitOnly, with PiP pinned to the top / in Split View.
struct ResizeExperiment: View {
    @Environment(Router.self) private var router
    @State private var fluid = false
    @State private var sceneSize: CGSize = .zero

    var body: some View {
        Group {
            if fluid { FluidScreen() } else { FixedHeightScreen() }
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { sceneSize = $0 }
        .overlay(alignment: .top) {
            Text("\(Bundle.main.bundleIdentifier ?? "") · \(Int(sceneSize.width))×\(Int(sceneSize.height)) · \(fluid ? "fluid" : "fixed")")
                .font(.caption2.monospaced()).padding(4).background(.yellow, in: .capsule)
        }
        .toolbar {
            ToolbarItem { Toggle("Fluid", systemImage: "arrow.up.and.down", isOn: $fluid) }
        }
        .navigationTitle("05 Resize")
        .onAppear { fluid = router.variant == "fluid" }
    }
}

/// Anti-pattern: fixed hero + fixed CTA, content squeezed in between.
private struct FixedHeightScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Hero().frame(height: 300)
            List(0..<20) { Text("Row \($0)") }
            Button("Primary action") {}
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, minHeight: 80)
        }
    }
}

/// Fluid: hero scales with the container and scrolls away; CTA stays compact.
private struct FluidScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Hero()
                    .containerRelativeFrame(.vertical) { height, _ in min(300, height * 0.35) }
                ForEach(0..<20) { Text("Row \($0)").frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal) }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ViewThatFits(in: .vertical) {
                Button("Primary action") {}.buttonStyle(.borderedProminent).controlSize(.large).padding()
                Button("Primary action") {}.buttonStyle(.borderedProminent).controlSize(.small).padding(4)
            }
        }
    }
}

private struct Hero: View {
    var body: some View {
        LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay { Text("HERO").font(.largeTitle.bold()).foregroundStyle(.white) }
    }
}
