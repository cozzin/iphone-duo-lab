import SwiftUI

/// Experiment 04: the hinge as an input/effect signal — never for layout (S4 2:35).
struct HingeExperiment: View {
    @State private var hinge: DeviceHinge?
    @State private var log: [String] = []
    @State private var scrub: Double = 0

    var body: some View {
        List {
            Section("Live") {
                if let hinge {
                    LabeledContent("Status", value: statusName(hinge.status))
                    LabeledContent("Angle", value: String(format: "%.1f° (%.3f rad)", hinge.angle.degrees, hinge.angle.radians))
                    Gauge(value: hinge.angle.degrees, in: 0...180) { Text("Angle") }
                } else {
                    ContentUnavailableView("Hinge Unavailable", systemImage: "rectangle.split.2x1")
                }
            }
            Section("Effect: parallax cards") {
                ZStack {
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hue: Double(i) / 4, saturation: 0.5, brightness: 0.9))
                            .frame(width: 160, height: 100)
                            .rotation3DEffect(.degrees(tilt * Double(i + 1) / 4), axis: (x: 1, y: 0, z: 0))
                            .offset(y: CGFloat(i) * 12)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            }
            Section("Input: scrub while partially open") {
                ProgressView(value: scrub)
                Text("Only active in .partiallyOpen; resets otherwise (S4 1:18 pattern)").font(.caption)
            }
            Section("Status log") {
                ForEach(log.reversed(), id: \.self) { Text($0).font(.caption.monospaced()) }
            }
        }
        .navigationTitle("04 Hinge")
        .onHingeChange { old, new in
            hinge = new.hinge
            if let h = new.hinge, h.status == .partiallyOpen {
                scrub = h.angle.degrees / 180
            } else {
                scrub = 0
            }
            if old.hinge?.status != new.hinge?.status {
                let entry = "\(Date.now.formatted(date: .omitted, time: .standard)) \(old.hinge.map { statusName($0.status) } ?? "nil") → \(new.hinge.map { statusName($0.status) } ?? "nil")"
                log.append(entry)
            }
        }
    }

    /// Effect only: tilt grows as the device folds from flat (180°).
    private var tilt: Double {
        guard let hinge, hinge.status == .partiallyOpen else { return 0 }
        return (180 - hinge.angle.degrees) / 3
    }
}
