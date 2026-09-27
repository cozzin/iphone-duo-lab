# Sources / 근거 자료

Accessed 2026-09-28. Primary sources come first. Each entry lists the claims it supports, keyed to the question numbers in the [README](../README.md).

**Legend:** 🍎 Apple primary · 🧰 SDK (Xcode 27.1 beta, 27A9269, iOS 27.1 simulator SDK) · 🧪 our own measurement · 👥 third party (secondary; verify before relying on it)

## Apple videos (Tech Talks, iPhone Duo series)

| ID | Title | Length | Speakers | Used for |
|----|-------|--------|----------|----------|
| [S1](https://developer.apple.com/videos/play/tech-talks/111461/) 🍎 | Prepare your app for iPhone Duo | ~9:30 | David Jackson | Q1 size classes, Q5 orientation, Q7 safe area |
| [S2](https://developer.apple.com/videos/play/tech-talks/111462/) 🍎 | Raise the bar with iPhone Duo | ~15 min | Anna, Maria | Q7 vertical bars |
| [S3](https://developer.apple.com/videos/play/tech-talks/111463/) 🍎 | Strike a pose with adaptive layouts on iPhone Duo | ~17 min | Maria, Harry | Q2 ArrangementView, Q3 reserved regions |
| [S4](https://developer.apple.com/videos/play/tech-talks/111464/) 🍎 | Leverage multiple displays and scenes on iPhone Duo | ~7 min | Chris Donegan, Alex Muller | Q4 hinge, Q5 multitasking |
| [S5](https://developer.apple.com/videos/play/tech-talks/111465/) 🍎 | Build a great camera experience for iPhone Duo | — | — | (camera; out of scope) |
| [S6](https://developer.apple.com/videos/play/tech-talks/111466/) 🍎 | Design for iPhone Duo | ~10 min | Marcos, Vince | Q1-b breakpoints, Q5 PiP, Q7 full-bleed |
| [S7](https://developer.apple.com/videos/play/wwdc2026/278/) 🍎 | Modernize your UIKit app (WWDC26) | ~16 min | — | Q5 orientation / UIRequiresFullScreen |

Timestamped links use `?time=<seconds>`, e.g. `https://developer.apple.com/videos/play/tech-talks/111466/?time=222` for 3:42.

## Apple documentation

| ID | Page | Used for |
|----|------|----------|
| [D1](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) 🍎 | HIG: Designing for iPhone Duo (new page, 2026-09-09) | Q1, Q3, Q5, Q7 |
| [D2](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo) 🍎 | Preparing your app for iPhone Duo | Q2 overlay placement, Q3, Q7 |
| [D3](https://developer.apple.com/documentation/swiftui/arrangementview) 🍎 | SwiftUI `ArrangementView` | Q2 |
| [D4](https://developer.apple.com/documentation/uikit/uiarrangementviewcontroller) 🍎 | UIKit `UIArrangementViewController` | Q2 |
| [D5](https://developer.apple.com/documentation/swiftui/reservedregion) 🍎 | SwiftUI `ReservedRegion` | Q3 |
| [D6](https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:)) 🍎 | SwiftUI `onHingeChange(isEnabled:_:)` | Q4 |
| [D7](https://developer.apple.com/documentation/swiftui/devicehinge) 🍎 | SwiftUI `DeviceHinge` | Q4 |
| [D8](https://developer.apple.com/documentation/uikit/uihingeinteraction) 🍎 | UIKit `UIHingeInteraction` | Q4 |
| [D9](https://developer.apple.com/documentation/swiftui/view/toolbarverticalbehavior(_:)) 🍎 | SwiftUI `toolbarVerticalBehavior(_:)` | Q7 |
| [D10](https://developer.apple.com/design/human-interface-guidelines/layout) 🍎 | HIG: Layout (size classes, safe areas) | Q1, Q7 |
| [D11](https://developer.apple.com/documentation/xcode/device-hub) 🍎 | Xcode Device Hub | Q8 |

Tip: most Apple doc pages are rendered with JavaScript. To get the raw content, fetch `https://developer.apple.com/tutorials/data/<path>.json`.

## SDK headers / Swift interfaces 🧰

Path: `Xcode-27.1.0-Beta.app/.../iPhoneSimulator27.1.sdk/System/Library/Frameworks/`

| ID | File | Used for |
|----|------|----------|
| H1 | `UIKit.framework/Headers/UIHinge.h`, `UIHingeInteraction.h` | Q4. `UIHinge.angle` is in **radians**; status values `.unknown/.closed/.partiallyOpen/.fullyOpen` |
| H2 | `UIKit.framework/Headers/UIViewReservedRegion.h`, `UIView.h` | Q3. `frame` includes `margins`; `isActive`; `.occlusion` / `.division` kinds |
| H3 | `UIKit.framework/Headers/UIArrangementViewController.h`, `UISplitArrangement.h`, `UIOverlayArrangement.h` | Q2 |
| H4 | `UIKit.framework/Headers/UIVerticalBarEdge.h`, `UIViewController.h` (preferredVerticalBarBehavior) | Q7 |
| H5 | `SwiftUICore.swiftmodule/*.swiftinterface`: `ArrangementView`, `ReservedRegion`, `DeviceHinge(.angle: Angle)`, `onHingeChange`, `splitArrangementLayoutRatio`, `overlayArrangementEdge`, `overlayArrangementZIndex`, `toolbarVerticalEdge` | Q2–Q4, Q7 |
| H6 | `SwiftUI.swiftmodule/*.swiftinterface`: `toolbarVerticalBehavior`, `toolbarVerticalCompressionBehavior(.prefersToolbarItems/.prefersTabBar)`, `ToolbarItemAxisBehavior`, `CameraCaptureAccessory` | Q7 |

## Our measurements 🧪

| ID | What | Used for |
|----|------|----------|
| M1 | `xcrun simctl io <udid> enumerate`: two integrated displays. Outer 1398×2034 px, inner 2007×2853 px (= 466×678 pt and 669×951 pt at 3x) | Q1, Q8 |
| M2 | `simctl io screenshot --display=<UUID>` captures each display separately | Q8 |
| M3 | `devicectl device motion hinge-angle -d <udid>` prints `Angle: 0.0° … Range:0-180°` in the simulator, but does not honor `--session-timeout` and hangs until `--timeout` | Q8 |
| M4 | `simctl ui` options are only `appearance`, `increase_contrast`, `content_size`. There is no posture control | Q8 |

## Third party 👥

| ID | Source | Used for |
|----|--------|----------|
| [T1](https://antongubarenko.substack.com/p/iphone-duo-group-lab-q-and-a) | Anton Gubarenko, "iPhone Duo Group Lab – Q&A" (2026-09-25). Notes from Apple's group lab | Q5 portrait-only, letterboxing, opting out of resizing |
| [T2](https://www.avanderlee.com/swiftui/iphone-duo-simulator/) | Antoine van der Lee, "iPhone Duo Simulator" (2026-09-22) | Q8. Holding ⌥ in Device Hub shows a hinge-angle slider |
| [T3](https://blakecrosley.com/blog/iphone-duo-for-developers) | Blake Crosley, "iPhone Duo for Developers: The 1.42 Problem" (2026-09-09/19) | Q1 display sizes, Q6 16:9 on a 1.42 display |
| [T4](https://www.swiftjectivec.com/iphone-duo-first-developer-good-to-knows/) | Jordan Morgan, "iPhone Duo: First Developer Good-to-Knows" (2026-09-09) | general |
| [T5](https://github.com/callstack/agent-device/pull/2717) | callstack/agent-device PR #2717: fold poses through the Device Hub accessibility API | Q8 |
| [T6](https://github.com/mobile-dev-inc/Maestro/issues/3617) | Maestro issue #3617: posture automation not supported | Q8 |
| [T7](https://developer.apple.com/forums/thread/847556) | Apple Developer Forums: Device Hub posture widget missing (old Device Hub launched) | Q8 |
| [T8](https://ecorpit.com/iphone-duo-adaptive-layout-arrangementview-reserved-regions-2026/) | ecorpit, ArrangementView/reserved regions overview | general |

## Known discrepancies to verify

1. **Are inactive reserved regions returned by default?** S3 (7:50) says only active regions are returned unless you pass `.includeInactive`. D5 says `reservedRegions` returns intersecting regions "regardless of whether they are currently active". → Verify in experiment 03.
2. **Orientation on the inner display.** S1 (2:46) says "The inner display doesn't honor your supported interface orientations." S1 (3:57) says "iPhone Duo respects your supported interface orientations, but your app will scale on the inner display". → Verify in experiment 05 with a portrait-only target.
3. **Name of the compression behavior value.** A summary of S2 wrote it as `.prefersTabBarItems`, but the SDK (H6) spells it `.prefersTabBar`. **The SDK wins.**
