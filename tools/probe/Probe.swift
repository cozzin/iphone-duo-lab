import SwiftUI
import os

let log = Logger(subsystem: "dev.duolab.probe", category: "probe")

@main
struct ProbeApp: App {
    var body: some Scene {
        WindowGroup {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-noVerticalBar") {
                // Vertical bar disabled: bars fall back to horizontal, trailing inset should go away (H4, D9)
                NavigationStack { ProbeView().navigationTitle("Probe").toolbar { ProbeToolbar() } }
                    .toolbarVerticalBehavior(.disabled)
            } else if args.contains("-withToolbar") {
                NavigationStack { ProbeView().navigationTitle("Probe").toolbar { ProbeToolbar() } }
            } else {
                ProbeView()
            }
        }
    }
}

struct ProbeView: View {
    @Environment(\.horizontalSizeClass) private var h
    @Environment(\.verticalSizeClass) private var v
    @Environment(\.toolbarVerticalEdge) private var verticalEdge
    @State private var hinge: String = "n/a"

    var body: some View {
        GeometryReader { proxy in
            let occ = proxy.reservedRegions(kind: .occlusion)
            let occAll = proxy.reservedRegions(kind: .occlusion, options: .includeInactive)
            let div = proxy.reservedRegions(kind: .division)
            let divAll = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let insets = proxy.safeAreaInsets
            ZStack(alignment: .topLeading) {
                // Full-bleed checkerboard background
                Canvas { ctx, size in
                    let s: CGFloat = 20
                    for x in stride(from: 0, to: size.width + s, by: s) {
                        for y in stride(from: 0, to: size.height + s, by: s) where (Int(x / s) + Int(y / s)) % 2 == 0 {
                            ctx.fill(Path(CGRect(x: x, y: y, width: s, height: s)), with: .color(.gray.opacity(0.25)))
                        }
                    }
                }
                .ignoresSafeArea()
                // Safe area boundary
                Rectangle()
                    .strokeBorder(.green, lineWidth: 3)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                ForEach(occAll) { r in
                    Rectangle().fill(.red.opacity(r.isActive ? 0.5 : 0.2))
                        .frame(width: r.frame.width, height: r.frame.height)
                        .offset(x: r.frame.minX, y: r.frame.minY)
                }
                ForEach(divAll) { r in
                    Rectangle().fill(.orange.opacity(r.isActive ? 0.5 : 0.2))
                        .frame(width: max(r.frame.width, 2), height: max(r.frame.height, 2))
                        .offset(x: r.frame.minX, y: r.frame.minY)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("size \(Int(proxy.size.width))×\(Int(proxy.size.height)) pt")
                    Text("h:\(String(describing: h)) v:\(String(describing: v))")
                    Text("safe T\(Int(insets.top)) L\(Int(insets.leading)) B\(Int(insets.bottom)) R\(Int(insets.trailing))")
                    Text("verticalBarEdge: \(String(describing: verticalEdge))")
                    Text("occlusion active \(occ.count) / all \(occAll.count)")
                    ForEach(occAll) { r in Text(" occ \(fmt(r.frame)) m\(fmt(r.margins)) active:\(r.isActive)") }
                    Text("division active \(div.count) / all \(divAll.count)")
                    ForEach(divAll) { r in Text(" div \(fmt(r.frame)) active:\(r.isActive)") }
                    Text("hinge: \(hinge)")
                }
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .padding(8)
                .background(.thinMaterial, in: .rect(cornerRadius: 8))
                .padding(12)
            }
            .onAppear {
                log.notice("PROBE size=\(proxy.size.width)x\(proxy.size.height) h=\(String(describing: h)) v=\(String(describing: v)) safe=T\(insets.top) L\(insets.leading) B\(insets.bottom) R\(insets.trailing) vEdge=\(String(describing: verticalEdge)) occ=\(occ.map { fmt($0.frame) }) occAll=\(occAll.map { "\(fmt($0.frame)) m\(fmt($0.margins)) a:\($0.isActive)" }) div=\(div.map { fmt($0.frame) }) divAll=\(divAll.map { "\(fmt($0.frame)) a:\($0.isActive)" })")
            }
        }
        .onHingeChange { _, new in
            if let hg = new.hinge {
                hinge = "\(String(describing: hg.status)) \(Int(hg.angle.degrees))°"
            } else {
                hinge = "nil"
            }
            log.notice("PROBE hinge=\(hinge)")
        }
    }
}

struct ProbeToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { Button("Close", systemImage: "xmark") {} }
        ToolbarItem(placement: .bottomBar) { Button("Share", systemImage: "square.and.arrow.up") {} }
        ToolbarItem(placement: .bottomBar) { Button("Favorite", systemImage: "heart") {} }
    }
}

func fmt(_ r: CGRect) -> String { "(\(Int(r.minX)),\(Int(r.minY)) \(Int(r.width))×\(Int(r.height)))" }
func fmt(_ e: EdgeInsets) -> String { "(\(Int(e.top)),\(Int(e.leading)),\(Int(e.bottom)),\(Int(e.trailing)))" }
