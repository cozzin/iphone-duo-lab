import SwiftUI

/// Experiment 01: structure switches on size class only; everything inside is fluid.
struct SizeClassExperiment: View {
    @Environment(\.horizontalSizeClass) private var h

    var body: some View {
        Group {
            if h == .regular {
                // Structure: two areas side by side (or stacked when tall) — ArrangementView decides.
                ArrangementView {
                    CatalogGrid()
                } secondary: {
                    DetailPanel()
                }
                .arrangementViewStyle(.split)
            } else {
                // Structure: single column
                CatalogGrid()
            }
        }
        .navigationTitle("01 Size class")
    }
}

/// Fluid content: column count comes from the container width, not from device or breakpoint.
/// When a division region exists (even inactive), prefer an even column count (S3 7:50, D1).
struct CatalogGrid: View {
    @State private var hasDivision = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(0..<30) { i in
                    SampleCard(index: i)
                }
            }
            .padding()
        }
        .onGeometryChange(for: Bool.self) { proxy in
            !proxy.reservedRegions(kind: .division, options: .includeInactive).isEmpty
        } action: { hasDivision = $0 }
        .overlay(alignment: .bottomLeading) {
            if hasDivision {
                Text("division present → prefer even columns")
                    .font(.caption2).padding(6).background(.orange.opacity(0.8), in: .capsule).padding()
            }
        }
    }
}

struct SampleCard: View {
    var index: Int
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hue: Double(index % 10) / 10, saturation: 0.5, brightness: 0.9))
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay(alignment: .bottomLeading) {
                Text("Item \(index)").font(.caption.bold()).padding(8)
            }
    }
}

struct DetailPanel: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Detail").font(.title2.bold())
                Text("Secondary content of the split arrangement. On the inner display it sits next to the grid; when the container is taller than wide it goes below.")
                ForEach(0..<8) { i in
                    Label("Row \(i)", systemImage: "circle.fill").foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(.background.secondary)
    }
}
