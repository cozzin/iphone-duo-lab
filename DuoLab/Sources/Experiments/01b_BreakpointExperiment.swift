import SwiftUI

/// Experiment 01-b: compare (A) size class, (B) 3 width tiers, (C) hybrid on the same screen,
/// and show where our tier disagrees with the system's size class.
struct BreakpointExperiment: View {
    enum Mode: String, CaseIterable { case a = "A size class", b = "B 3 tiers", c = "C hybrid" }

    @Environment(Router.self) private var router
    @Environment(\.horizontalSizeClass) private var h
    @State private var mode: Mode = .b
    @State private var containerWidth: CGFloat = 0

    /// Example tiers for a generic design system. Measured on the container, not the screen.
    enum Tier: String { case s = "S", m = "M", l = "L" }
    static func tier(for width: CGFloat) -> Tier {
        switch width {
        case ..<500: .s
        case ..<800: .m
        default: .l
        }
    }

    var body: some View {
        let tier = Self.tier(for: containerWidth)
        // What each approach considers "wide" (two-column structure)
        let wantsTwoColumns: Bool = switch mode {
        case .a, .c: h == .regular
        case .b: tier != .s
        }
        let systemWide = h == .regular

        VStack(spacing: 0) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()

            HStack {
                Text("container \(Int(containerWidth))pt · tier \(tier.rawValue) · system h:\(short(h))")
                Spacer()
                if wantsTwoColumns != systemWide {
                    Text("MISMATCH").bold().padding(.horizontal, 8).background(.red, in: .capsule).foregroundStyle(.white)
                }
            }
            .font(.caption.monospaced())
            .padding(.horizontal)

            Group {
                if wantsTwoColumns {
                    HStack(spacing: 0) {
                        grid(columns: columns(tier: tier))
                        DetailPanel().frame(maxWidth: 320)
                    }
                } else {
                    grid(columns: columns(tier: tier))
                }
            }
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { containerWidth = $0 }
        }
        .navigationTitle("01-b Breakpoints")
        .onAppear {
            if let v = router.variant, let m = Mode.allCases.first(where: { $0.rawValue.hasPrefix(v.uppercased()) }) { mode = m }
        }
    }

    private func columns(tier: Tier) -> [GridItem] {
        switch mode {
        case .b:
            // Fixed column count per tier
            let n = switch tier { case .s: 2; case .m: 3; case .l: 4 }
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: n)
        case .a, .c:
            // Fluid density from container width
            return [GridItem(.adaptive(minimum: 150), spacing: 12)]
        }
    }

    private func grid(columns: [GridItem]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<24) { SampleCard(index: $0) }
            }
            .padding()
        }
    }
}
