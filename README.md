# DuoLab — iPhone Duo adaptive layout experiments

A Tuist-based SwiftUI sample app for testing Apple's guidance on building apps for **iPhone Duo** (the foldable iPhone, iOS 27.1).

> 한국어 요약은 [README.ko.md](README.ko.md)에 있습니다.

## Experiments

| # | Question | Code | Report |
|---|----------|------|--------|
| 1 | Why does Apple recommend size classes, and is targeting only compact/regular width realistic? | `DuoLab/Sources/Experiments/01_SizeClass` | [docs/research/01-size-class.md](docs/research/01-size-class.md) |
| 1-b | Width-breakpoint "3 tiers" vs size classes vs hybrid | same | [docs/research/01b-breakpoint-vs-size-class.md](docs/research/01b-breakpoint-vs-size-class.md) |
| 2 | Player render on top, controls below in the partially open posture: `ArrangementView` | `02_PlayerArrangement` | [docs/research/02-player-arrangement.md](docs/research/02-player-arrangement.md) |
| 3 | Custom popups and the hinge: how to avoid it | `03_CustomPopup` | [docs/research/03-custom-popup.md](docs/research/03-custom-popup.md) |
| 4 | Practical uses of `.onHingeChange` | `04_Hinge` | [docs/research/04-hinge.md](docs/research/04-hinge.md) |
| 5 | PiP pinned on top + resized app, portrait-only apps | `05_PiPResize` | [docs/research/05-pip-resize.md](docs/research/05-pip-resize.md) |
| 6 | Additional considerations for adapting apps | — | [docs/considerations.md](docs/considerations.md) |
| 7 | Full-bleed backgrounds vs the Dynamic Island / safe area | `07_SafeArea` | [docs/research/07-safe-area-dynamic-island.md](docs/research/07-safe-area-dynamic-island.md) |
| 8 | Automated layout screenshots | `tools/duo-capture` | [docs/research/08-screenshot-automation.md](docs/research/08-screenshot-automation.md) |

Apple session notes: [docs/apple/en](docs/apple/en) · [docs/apple/ko](docs/apple/ko) · Sources: [docs/sources.md](docs/sources.md)

## Requirements

- Xcode 27.1 (iOS 27.1 SDK, iPhone Duo simulator)
- [Tuist](https://tuist.dev)

## Run

```sh
tuist generate
xcodebuild -scheme DuoLab -destination 'platform=iOS Simulator,name=iPhone Duo' build
```
