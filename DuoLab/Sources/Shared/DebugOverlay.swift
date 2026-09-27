import SwiftUI
import os

let duoLog = Logger(subsystem: "dev.duolab.app", category: "layout")

extension View {
    /// Shows size classes, container size, safe area, vertical bar edge, reserved regions and hinge state.
    /// Every capture in docs/images uses this overlay so screenshots double as measurements.
    func debugOverlay(isEnabled: Bool = true) -> some View {
        modifier(DebugOverlayModifier(isEnabled: isEnabled))
    }
}

struct LayoutSnapshot: Equatable {
    var size: CGSize = .zero
    var insets: EdgeInsets = .init()
    var occlusions: [ReservedRegion] = []
    var divisions: [ReservedRegion] = []
}

private struct DebugOverlayModifier: ViewModifier {
    var isEnabled: Bool
    @Environment(\.horizontalSizeClass) private var h
    @Environment(\.verticalSizeClass) private var v
    @Environment(\.toolbarVerticalEdge) private var verticalEdge
    @State private var snapshot = LayoutSnapshot()
    @State private var hinge: DeviceHinge?

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: LayoutSnapshot.self) { proxy in
                LayoutSnapshot(
                    size: proxy.size,
                    insets: proxy.safeAreaInsets,
                    occlusions: proxy.reservedRegions(kind: .occlusion, options: .includeInactive),
                    divisions: proxy.reservedRegions(kind: .division, options: .includeInactive)
                )
            } action: { new in
                snapshot = new
                duoLog.notice("LAYOUT \(describe(new), privacy: .public)")
            }
            .onHingeChange { _, new in hinge = new.hinge }
            .overlay {
                if isEnabled {
                    ZStack(alignment: .topLeading) {
                        ForEach(snapshot.occlusions + snapshot.divisions) { region in
                            Rectangle()
                                .fill((region.kind == .division ? Color.orange : .red).opacity(region.isActive ? 0.45 : 0.15))
                                .frame(width: max(region.frame.width, 2), height: max(region.frame.height, 2))
                                .offset(x: region.frame.minX, y: region.frame.minY)
                        }
                        Text(label)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .padding(6)
                            .background(.black.opacity(0.7), in: .rect(cornerRadius: 6))
                            .foregroundStyle(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .allowsHitTesting(false)
                }
            }
    }

    private var label: String {
        let s = snapshot
        return """
        \(Int(s.size.width))×\(Int(s.size.height))pt  h:\(short(h)) v:\(short(v))
        safe T\(Int(s.insets.top)) L\(Int(s.insets.leading)) B\(Int(s.insets.bottom)) R\(Int(s.insets.trailing))  vbar:\(verticalEdge.map { "\($0)" } ?? "-")
        div \(s.divisions.filter(\.isActive).count)/\(s.divisions.count)  occ \(s.occlusions.filter(\.isActive).count)/\(s.occlusions.count)
        hinge \(hinge.map { "\(statusName($0.status)) \(Int($0.angle.degrees))°" } ?? "nil")
        """
    }

    private func describe(_ s: LayoutSnapshot) -> String {
        "size=\(Int(s.size.width))x\(Int(s.size.height)) h=\(short(h)) v=\(short(v)) safe=\(Int(s.insets.top)),\(Int(s.insets.leading)),\(Int(s.insets.bottom)),\(Int(s.insets.trailing)) div=\(s.divisions.map { "\($0.frame) active=\($0.isActive)" }) occ=\(s.occlusions.map { "\($0.frame) active=\($0.isActive)" })"
    }
}

func short(_ sizeClass: UserInterfaceSizeClass?) -> String {
    switch sizeClass {
    case .compact: "C"
    case .regular: "R"
    default: "-"
    }
}

func statusName(_ status: DeviceHinge.Status) -> String {
    switch status {
    case .closed: "closed"
    case .partiallyOpen: "partiallyOpen"
    case .fullyOpen: "fullyOpen"
    default: "unknown"
    }
}
