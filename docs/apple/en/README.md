# Apple iPhone Duo materials: English notes

Summaries of Apple's iPhone Duo sessions and documentation, organized so each point can be cited. Every note has a TL;DR, timestamped key points (with links to the exact second), verbatim quotes for important claims, and SDK signatures checked against the Xcode 27.1 beta SDK.

| Note | Source |
|------|--------|
| [111461 Prepare your app](111461-prepare-your-app.md) | Tech Talk: SDK, size classes, orientation, safe areas |
| [111462 Raise the bar](111462-raise-the-bar.md) | Tech Talk: vertical bars |
| [111463 Strike a pose](111463-strike-a-pose.md) | Tech Talk: reserved regions, ArrangementView |
| [111464 Multiple displays and scenes](111464-multiple-displays-and-scenes.md) | Tech Talk: hinge API, multitasking, scenes |
| [111466 Design for iPhone Duo](111466-design-for-iphone-duo.md) | Tech Talk: design principles, PiP, fold avoidance |
| [WWDC26-278 Modernize your UIKit app](wwdc26-278-modernize-uikit.md) | Resizable iPhone apps, orientation, UIRequiresFullScreen |
| [HIG + developer docs](hig-and-developer-docs.md) | HIG page, overview article, API reference pages |

## Cross-cutting facts (with source IDs from [sources.md](../../sources.md))

| Fact | Source |
|------|--------|
| Outer display: compact width (portrait: C/R, landscape: C/C). Inner display: regular/regular | S1 2:46, D1 |
| Outer 466×678 pt, inner 669×951 pt (3x) | M1 (our measurement), T3 |
| Design two layouts only: compact (outer) and regular (inner). Avoid breakpoints | S6 3:42, D1 |
| Inner display ignores supported interface orientations; iOS 27 treats them as a preference in resizable environments | S1 2:46, S7 6:50, T1 |
| Bars move to a vertical bar on the side (except inner display in portrait). The Dynamic Island and status bar share that column | S2, S6 0:28, D1 |
| Safe areas are asymmetric | S1 7:30, D1 |
| Backgrounds full-bleed, controls inside the safe area; full width is OK when nothing conflicts with the Dynamic Island or status bar | S1 6:06–7:07, S6 6:33, D1 |
| System alerts, sheets, menus, and popovers avoid the fold automatically; custom UI uses `ReservedRegion` | S3 5:12, S6 9:28, D1 |
| Hinge API is for effects and interactions, not layout | S4 2:35 |
| PiP can be pinned to the top, and the app resizes vertically | S4 2:59, S6 ~1:40 |
| Overlay arrangement when partially open: primary trailing/bottom, secondary leading/top | D2 |

Korean version: [../ko](../ko/README.md)
