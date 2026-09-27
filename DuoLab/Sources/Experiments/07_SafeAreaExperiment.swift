import SwiftUI

/// Experiment 07: full-bleed background, safe area boundary, corner buttons inside and outside the safe area.
struct SafeAreaExperiment: View {
    @Environment(Router.self) private var router
    @State private var verticalBarDisabled = false

    var body: some View {
        ZStack {
            Checkerboard().ignoresSafeArea()          // background: full bleed (S1 7:07)
            Rectangle().strokeBorder(.green, lineWidth: 3)   // safe area boundary
            cornerButtons.ignoresSafeArea()           // outside: may collide with camera / status column
            cornerButtons                             // inside: safe
                .tint(.green)
        }
        .navigationTitle("07 Safe area")
        .toolbar {
            ToolbarItem { Toggle("No vertical bar", systemImage: "sidebar.right", isOn: $verticalBarDisabled) }
        }
        .toolbarVerticalBehavior(verticalBarDisabled ? .disabled : .automatic)
        .onAppear { verticalBarDisabled = router.variant == "noVerticalBar" }
    }

    private var cornerButtons: some View {
        VStack {
            HStack { corner("↖"); Spacer(); corner("↗") }
            Spacer()
            HStack { corner("↙"); Spacer(); corner("↘") }
        }
    }

    private func corner(_ title: String) -> some View {
        Button(title) {}.buttonStyle(.borderedProminent)
    }
}

struct Checkerboard: View {
    var body: some View {
        Canvas { ctx, size in
            let s: CGFloat = 20
            for x in stride(from: 0, to: size.width + s, by: s) {
                for y in stride(from: 0, to: size.height + s, by: s) where (Int(x / s) + Int(y / s)) % 2 == 0 {
                    ctx.fill(Path(CGRect(x: x, y: y, width: s, height: s)), with: .color(.gray.opacity(0.25)))
                }
            }
        }
    }
}
