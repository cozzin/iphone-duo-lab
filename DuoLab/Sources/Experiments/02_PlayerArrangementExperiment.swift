import AVKit
import SwiftUI

/// Experiment 02: render on top / controls below when partially open.
/// Variants follow docs/research/02-player-arrangement.md.
struct PlayerArrangementExperiment: View {
    enum Variant: String, CaseIterable {
        case overlay, overlayVertical, split, manual
    }

    @Environment(Router.self) private var router
    @State private var variant: Variant = .overlay
    @State private var player = AVPlayer(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)

    var body: some View {
        Group {
            switch variant {
            case .overlay:
                // Apple's documented pattern: controls = primary, video = secondary (D3)
                ArrangementView {
                    PlayerControls(player: player)
                } secondary: {
                    VideoSurface(player: player)
                }
                .arrangementViewStyle(.overlay)
            case .overlayVertical:
                ArrangementView {
                    PlayerControls(player: player)
                } secondary: {
                    VideoSurface(player: player)
                }
                .arrangementViewStyle(.overlay.axes(.vertical))
            case .split:
                // Split stacks primary on top when taller than wide → render must be primary
                ArrangementView {
                    VideoSurface(player: player)
                } secondary: {
                    PlayerControls(player: player)
                }
                .arrangementViewStyle(.split)
            case .manual:
                ManualHingeSplit(top: { VideoSurface(player: player) },
                                 bottom: { PlayerControls(player: player) })
            }
        }
        .toolbar {
            ToolbarItem {
                Menu("Variant", systemImage: "square.split.1x2") {
                    Picker("Variant", selection: $variant) {
                        ForEach(Variant.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                }
            }
        }
        .navigationTitle("02 \(variant.rawValue)")
        .onAppear {
            if let v = router.variant.flatMap(Variant.init(rawValue:)) { variant = v }
        }
    }
}

struct VideoSurface: View {
    var player: AVPlayer
    var body: some View {
        VideoPlayer(player: player)
            .background(.black)
            .overlay(alignment: .topLeading) {
                Text("RENDER").font(.caption.bold()).padding(6).background(.yellow, in: .capsule).padding(8)
            }
    }
}

struct PlayerControls: View {
    var player: AVPlayer
    @Environment(\.overlayArrangementZIndex) private var zIndex
    @Environment(\.splitArrangementAxis) private var splitAxis
    @State private var progress: Double = 0.3

    var body: some View {
        VStack(spacing: 16) {
            Text("CONTROLS  zIndex:\(zIndex) splitAxis:\(splitAxis.map { "\($0)" } ?? "-")")
                .font(.caption.monospaced().bold())
            Slider(value: $progress)
            HStack(spacing: 32) {
                Button("Back 10s", systemImage: "gobackward.10") {}
                Button("Play", systemImage: "playpause.fill") {
                    player.timeControlStatus == .playing ? player.pause() : player.play()
                }
                .font(.largeTitle)
                Button("Forward 10s", systemImage: "goforward.10") {}
                Button("Subtitles", systemImage: "captions.bubble") {}
            }
            .labelStyle(.iconOnly)
        }
        .padding()
        // When layered over the video (zIndex > 0) behave like a translucent HUD; side-by-side → solid panel.
        .frame(maxWidth: .infinity, maxHeight: zIndex > 0 ? nil : .infinity, alignment: .bottom)
        .background(zIndex > 0 ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.background.secondary))
    }
}

/// Comparison: the same result without ArrangementView, using the division region directly.
struct ManualHingeSplit<Top: View, Bottom: View>: View {
    @ViewBuilder var top: Top
    @ViewBuilder var bottom: Bottom

    var body: some View {
        GeometryReader { proxy in
            let division = proxy.reservedRegions(kind: .division).first { $0.isActive && $0.frame.width > $0.frame.height }
            if let d = division?.frame {
                VStack(spacing: 0) {
                    top.frame(height: d.minY)
                    Color.clear.frame(height: d.height)
                    bottom.frame(maxHeight: .infinity)
                }
            } else {
                ZStack(alignment: .bottom) { top; bottom }
            }
        }
    }
}
