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
| M5 | Probe app (`tools/probe`), outer display, closed, portrait, **iOS 27.1 SDK**: window 466×678 pt; `GeometryReader` size 382×644; safe area T0 L0 B34 **R84**; h=compact, v=regular; `toolbarVerticalEdge=.trailing`; occlusion and division regions: none (also with `.includeInactive`). **Superseded by M9:** the probe logged only on `onAppear` and read the regions through `GeometryReader`; hinge `closed 0°` | Q1, Q3, Q7 |
| M7 | Probe `-withToolbar` (NavigationStack + toolbar, 27.1): content 382×562; safe area T82 L0 B34 R84; Close at the top of the vertical bar, bottom-bar items at the bottom | Q7 |
| M8 | Probe `-noVerticalBar` (`toolbarVerticalBehavior(.disabled)`): content 466×462; safe area T134 L0 B82 R0; status bar goes horizontal to the left of the top-right camera; (occlusion reading unreliable, see M9) | Q7 |
| M9 | DuoLab debug overlay (`onGeometryChange`, reactive), outer display, closed, vertical bar active: **2 active occlusion regions**: camera hole (399.7, 29.3, 37×37) and camera + status column (382, 0, 84×170), both outside the 382 pt view bounds. The first geometry pass reports `[]`, and the regions follow immediately | Q3, Q7 |
| M10 | Experiment 02, outer display, closed: `.split` → render (primary) on top, controls below at (0, 363, 382×281); `.overlay` → controls (primary) layered over the full-size video (secondary), controls frame = full content area (0, 82, 382×562). `overlayArrangementZIndex` = 0 in both cases | Q2 |
| M11 | Half-open 130° (book posture: inner display landscape, vertical hinge): view 867×635 pt (h=R, v=R), safe T0 L0 B34 R84 (vertical bar trailing); **division (455.5, 0, 40×669) active**; inner camera occlusion (677.3, 21, 58×37) **inactive**; status column occlusion active. Exp 02 `.overlay` → secondary (video) leading, primary (controls) trailing at (495.5, 82, 371.5×553); `.split` gives the same layout; zIndex 0 | Q2, Q3, Q7 |
| M12 | Fully open 180° (inner display landscape): view 867×635 pt, h=R v=R, safe T0 L0 B34 R84; division (455.5, 0, **40×669**) reported **inactive** (width 40, not 0 as S3 7:50 says); inner camera occlusion inactive. Exp 02 `.overlay` → controls layered over the full video again (0, 82, 867×553); `.split` → always 50/50 side by side (433.5 pt each). Exp 05 **portrait-only target rendered landscape 867×635** (orientation lock ignored on the inner display, confirming S1 2:46) | Q2, Q3, Q5 |
| M13 | Laptop posture (inner display portrait, horizontal hinge, 130°): view 669×835 pt, h=R v=R, safe **T82 L0 B34 R0, no vertical bar** (inner portrait keeps horizontal bars, matching D1/S6); division (0, 373.5, 669×40) active. Exp 02 `.overlay` → **video top, controls bottom** at (0, 495.5, 669×421.5); `.split` gives the same layout. Exp 03: naive custom popup straddles the hinge; hinge-aware popup sits in the bottom region; system alert moves to the bottom region; medium sheet stops just below the hinge; a plain SwiftUI `Button` stays on the hinge. **Default `reservedRegions(kind:)` (no options) returned only active regions** (occ 1 of 2, div 1 of 1; a sheet with an inactive camera region returned occ 0) | Q2, Q3, Q7 |
| M6 | The same probe linked with **SDK 27.0** (compatibility): window 386 pt wide, left of the camera/status column; safe area R0; `toolbarVerticalEdge=nil`. Reproduces S1 0:30 | Q5, Q7 |

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

0. **Width of the inactive division.** S3 (7:50) says it "has a width of zero" when flat. Measured (M12): it is reported inactive, but its frame is still **40 pt wide**. Filter on `isActive` rather than on the width.

1. **Are inactive reserved regions returned by default?** Resolved (M13): **only active regions** are returned without options, as S3 (7:50) says. D5's "regardless of whether they are currently active" does not match the runtime behavior.
2. **Orientation on the inner display.** S1 (2:46) says "The inner display doesn't honor your supported interface orientations." S1 (3:57) says "iPhone Duo respects your supported interface orientations, but your app will scale on the inner display". → Verify in experiment 05 with a portrait-only target.
3. **Is the outer camera an occlusion region?** Resolved: **yes** (M9), consistent with D2. The first probe (M5, M8) missed it because it read the regions once, before they arrived. Lesson: read reserved regions reactively (`onGeometryChange`), not once in `onAppear`.
4. **Name of the compression behavior value.** A summary of S2 wrote it as `.prefersTabBarItems`, but the SDK (H6) spells it `.prefersTabBar`. **The SDK wins.**
