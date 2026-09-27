# DuoLab: iPhone Duo adaptive layout experiments

A Tuist-based SwiftUI sample app and research notes. They verify Apple's iPhone Duo guidance (foldable iPhone, iOS 27.1) by **measuring and capturing on the iPhone Duo simulator**.

한국어: [README.ko.md](README.ko.md)

---

## ⭐ Hinge avoidance strategy (verified)

How to keep each kind of screen off the fold when the device is partially open. Every row was checked on the simulator: closed, fully open, book posture, and laptop posture.

| Screen type | What to do | Posture-specific code |
|---|---|---|
| Scrolling content (lists, grids, feeds) | **Leave it.** People can scroll it off the fold. | none |
| Centered layouts (sign-in, empty states, onboarding) | Make **two columns** with `ArrangementView(.split.axes(.horizontal))`. | none |
| Two-part screens (video + controls, etc.) | `ArrangementView(.overlay)`. Layered normally, separated when folded. | none |
| Custom alerts / popups / toasts | Stack an **overlay `ArrangementView` above the screen** in a ZStack (`hingeAwarePopup`). | none |
| Floating elements (FAB, mini bars) | Anchor them to a **corner**, not the center. The fold is always the center line. | none |
| Backgrounds | **Fill across the fold.** | none |

**Common rule:** never derive layout from the hinge width (40 pt) or the hinge angle. Let `ArrangementView` decide.

### 1) Custom alert: overlay ArrangementView stacked above the screen

```swift
extension View {
    func hingeAwarePopup<Popup: View>(isPresented: Bool, @ViewBuilder popup: () -> Popup) -> some View {
        overlay {
            if isPresented {
                ArrangementView {
                    popup().frame(maxWidth: .infinity, maxHeight: .infinity)   // primary: the popup
                } secondary: {
                    Color.clear.allowsHitTesting(false)                        // secondary: empty
                }
                .arrangementViewStyle(.overlay)
            }
        }
    }
}
```

| Fully open: centered | Book: trailing of the fold | Laptop: below the fold | Closed: centered |
|---|---|---|---|
| <img src="docs/images/03/open-zAlert-inner.png" width="220"> | <img src="docs/images/03/half130-zAlert-book-inner.png" width="220"> | <img src="docs/images/03/half130-zAlert-laptop-inner.png" width="160"> | <img src="docs/images/03/closed-zAlert-outer.png" width="150"> |

The screen underneath keeps its full size; only the popup moves. Careful: if the screen itself goes **inside** the ArrangementView (as the secondary), it shrinks to half as soon as the device folds ([evidence](docs/research/03b-hinge-avoidance-strategy.md)).

### 2) Centered layouts: two columns

| As is (book) | Two columns (book) | Two columns (open) | Two columns (closed) |
|---|---|---|---|
| <img src="docs/images/03/half130-centerAsIs-book-inner.png" width="220"> | <img src="docs/images/03/half130-centerSplit-book-inner.png" width="220"> | <img src="docs/images/03/open-centerSplit-inner.png" width="220"> | <img src="docs/images/03/closed-centerSplit-outer.png" width="150"> |
| Fields and the **button sit on the crease** | Form leading, illustration trailing | 50:50 columns | Form only |

### 3) Two-part screens: `.overlay`

| Closed | Fully open | Book | Laptop |
|---|---|---|---|
| <img src="docs/images/02/closed-overlay-outer.png" width="150"> | <img src="docs/images/02/open-overlay-inner.png" width="220"> | <img src="docs/images/02/half130-overlay-inner.png" width="220"> | <img src="docs/images/02/half130-overlay-laptop-inner.png" width="160"> |
| Controls over video | Layered | Video leading / controls trailing | **Video top / controls bottom** |

Details: [strategy doc (Korean)](docs/research/03b-hinge-avoidance-strategy.md)

---

## Experiments

| # | Question | Code | Report |
|---|----------|------|--------|
| 1 | Why size classes, and is targeting only compact/regular width realistic? | `Experiments/01_SizeClassExperiment.swift` | [01](docs/research/01-size-class.md) |
| 1-b | Width breakpoints ("3 tiers") vs size classes vs hybrid | `01b_BreakpointExperiment.swift` | [01-b](docs/research/01b-breakpoint-vs-size-class.md) |
| 2 | Video on top, controls below when partially open (`ArrangementView`) | `02_PlayerArrangementExperiment.swift` | [02](docs/research/02-player-arrangement.md) |
| 3 | Custom popups and the hinge; centered layouts | `03_CustomPopupExperiment.swift`, `03c_CenteredLayoutExperiment.swift` | [03](docs/research/03-custom-popup.md), [03-b](docs/research/03b-hinge-avoidance-strategy.md) |
| 4 | Practical uses of `.onHingeChange` | `04_HingeExperiment.swift` | [04](docs/research/04-hinge.md) |
| 5 | Pinned PiP / portrait-only apps | `05_ResizeExperiment.swift` | [05](docs/research/05-pip-resize.md) |
| 6 | Additional considerations | — | [considerations](docs/considerations.md) |
| 7 | Full-bleed backgrounds vs the Dynamic Island / safe area | `07_SafeAreaExperiment.swift` | [07](docs/research/07-safe-area-dynamic-island.md) |
| 8 | Automated layout screenshots | `tools/duo-capture` | [08](docs/research/08-screenshot-automation.md) |

- Capture gallery: [docs/findings.md](docs/findings.md)
- Apple session notes: [docs/apple/en](docs/apple/en/README.md) · [docs/apple/ko](docs/apple/ko/README.md)
- Sources and measurements (M1–M22): [docs/sources.md](docs/sources.md)

Reports are written in Korean with English summaries.

## Run

Requires Xcode 27.1 and [Tuist](https://tuist.dev).

```sh
tuist generate
xcodebuild -workspace DuoLab.xcworkspace -scheme DuoLab -destination 'platform=iOS Simulator,name=iPhone Duo' build

# Set a pose in Device Hub, then capture every experiment at that pose (outer and inner displays).
tools/duo-capture/capture.sh
```

Screenshot names: `<pose>-<variant>-<display>.png`. `closed`, `open` (landscape; `-portrait` for portrait) and `half130` (130°; `-book` or unlabeled = book posture, `-laptop` = laptop posture). All images are simulator captures of this app; no frames from Apple's videos are included.
