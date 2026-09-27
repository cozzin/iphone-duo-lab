import SwiftUI

// Reusable tools from docs/research/03b-hinge-avoidance-strategy.md.
// None of these are Apple APIs; they are thin wrappers around ArrangementView and ReservedRegion.

// MARK: - Popups (validated: M16–M19)

extension View {
    /// Presents `popup` above this view, placed by an overlay `ArrangementView`.
    /// Folded: the system moves it into the trailing (book) or bottom (laptop) region.
    /// Flat or closed: centered. The view underneath keeps its full size.
    func hingeAwarePopup<Popup: View>(isPresented: Bool, @ViewBuilder popup: () -> Popup) -> some View {
        overlay {
            if isPresented {
                ArrangementView {
                    popup().frame(maxWidth: .infinity, maxHeight: .infinity)
                } secondary: {
                    Color.clear.allowsHitTesting(false)
                }
                .arrangementViewStyle(.overlay)
                .background(.black.opacity(0.2))
            }
        }
    }
}

// MARK: - Active divisions, published once from the root

/// Frames of the *active* division regions (the fold), in global coordinates.
struct ActiveDivisions: Equatable {
    var frames: [CGRect] = []
}

extension EnvironmentValues {
    @Entry var activeDivisions = ActiveDivisions()
}

extension View {
    /// Attach once near the root. Reads divisions reactively: the first layout pass reports none (M9).
    func providesActiveDivisions() -> some View {
        modifier(ActiveDivisionsProvider())
    }
}

private struct ActiveDivisionsProvider: ViewModifier {
    @State private var divisions = ActiveDivisions()

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: ActiveDivisions.self) { proxy in
                let origin = proxy.frame(in: .global).origin
                // Default query returns only active regions (M13); filter anyway to be explicit.
                let frames = proxy.reservedRegions(kind: .division, layoutDirectionBehavior: .fixed)
                    .filter(\.isActive)
                    .map { $0.frame.offsetBy(dx: origin.x, dy: origin.y) }
                return ActiveDivisions(frames: frames)
            } action: { divisions = $0 }
            .environment(\.activeDivisions, divisions)
    }
}

// MARK: - Floating elements

enum HingeAvoidancePreference {
    /// Move to whichever side needs the smaller shift.
    case nearest
    /// Move below a horizontal hinge / to the trailing side of a vertical hinge (Apple's default direction for alerts).
    case afterHinge
}

extension View {
    /// For floating, non-scrolling controls (FAB, toast, bottom CTA). Does nothing unless the view
    /// overlaps an active fold; then shifts it by the minimum distance to clear the fold.
    func avoidingHinge(prefer: HingeAvoidancePreference = .afterHinge) -> some View {
        modifier(AvoidingHinge(preference: prefer))
    }
}

private struct AvoidingHinge: ViewModifier {
    var preference: HingeAvoidancePreference
    @Environment(\.activeDivisions) private var divisions
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var measured: CGRect = .zero
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            // The measured frame includes the current offset; subtract it to get the un-shifted frame.
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { measured = $0 }
            .offset(offset)
            .onChange(of: Inputs(frame: measured, divisions: divisions.frames), initial: true) { _, inputs in
                let original = inputs.frame.offsetBy(dx: -offset.width, dy: -offset.height)
                let target = shift(for: original, divisions: inputs.divisions)
                if target != offset {
                    withAnimation(.snappy) { offset = target }
                }
            }
    }

    private struct Inputs: Equatable {
        var frame: CGRect
        var divisions: [CGRect]
    }

    private func shift(for frame: CGRect, divisions: [CGRect]) -> CGSize {
        guard let fold = divisions.first(where: { $0.intersects(frame) }) else { return .zero }
        let verticalFold = fold.height > fold.width
        if verticalFold {
            let toLeft = -(frame.maxX - fold.minX)
            let toRight = fold.maxX - frame.minX
            let trailing = layoutDirection == .leftToRight ? toRight : toLeft
            let dx = preference == .nearest ? (abs(toLeft) < abs(toRight) ? toLeft : toRight) : trailing
            return CGSize(width: dx, height: 0)
        } else {
            let up = -(frame.maxY - fold.minY)
            let down = fold.maxY - frame.minY
            let dy = preference == .nearest ? (abs(up) < abs(down) ? up : down) : down
            return CGSize(width: 0, height: dy)
        }
    }
}
