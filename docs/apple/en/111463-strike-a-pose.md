# Strike a pose with adaptive layouts on iPhone Duo (Tech Talk 111463)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/tech-talks/111463/ |
| Length | ~17 min |
| Speakers | Maria (Human Interface Designer), Harry (UI Frameworks Engineer) |
| Accessed | 2026-09-28 |

## TL;DR
- The hinge and the two cameras are **reserved regions**. The fold is a **division** region, active only while the device is folded. The inner camera is an **occlusion** region, active only while the camera is in use.
- System lightweight presentations (alerts, action sheets, menus, popovers) **reposition around reserved regions automatically**. For custom UI, query `reservedRegions(kind:)` and apply **displacement** yourself.
- `ArrangementView` (split or overlay) is a layout container for two views that adapts to size class, aspect ratio, and active divisions.

## Key points (timestamped)

| Time | Point |
|------|-------|
| [0:27](https://developer.apple.com/videos/play/tech-talks/111463/?time=27) | Reserved regions = hinge + outer and inner cameras. "Treat these just like any other areas your layout already adapts to, such as the window controls on iPadOS." |
| [1:29](https://developer.apple.com/videos/play/tech-talks/111463/?time=89) | When partially folded, the display curves through the center (book analogy). Content and controls that span the fold are hard to see and use. |
| [2:26](https://developer.apple.com/videos/play/tech-talks/111463/?time=146) | **Displacement**: adjust the frames of existing elements so they stay visible and reachable. Move elements independently or together. "Be mindful of excessive movement." **"Continuous scrolling content like articles, feeds, documents, and lists don't displace."** |
| [4:00](https://developer.apple.com/videos/play/tech-talks/111463/?time=240) | Where content moves depends on posture. In the book posture, **alerts move to the trailing side** ("closer to where they'll appear as the device closes"). When propped on a table, the **top region is for content viewed at a distance** and the **bottom region is for interactive controls, e.g. media controls**. "When multiple regions are suitable, prioritize keeping things contextual." |
| [5:12](https://developer.apple.com/videos/play/tech-talks/111463/?time=312) | "Action sheets, alerts, menus, and popovers … The system automatically repositions components around the reserved region." Split views go to 50/50. In grids, keep the outer margins and add spacing around the hinge. |
| [6:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=399) | Query with `GeometryProxy.reservedRegions(kind:)` (from `GeometryReader` or `onGeometryChange`) or `UIView.reservedRegions(kind:)`. |
| [7:50](https://developer.apple.com/videos/play/tech-talks/111463/?time=470) | Regions can be active or inactive. "By default, only active ones will be returned" → `.includeInactive`. "On iPhone Duo, the fold's division region is only active when someone has folded the device. When flat, it's inactive and has a width of zero." Tip: use inactive regions for high-level decisions, e.g. prefer an **even number of grid columns** whenever a division exists. The occlusion region (FaceTime camera) is active only while the camera is on. |
| [8:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=519) | System containers (`NavigationStack`, `NavigationSplitView`, `TabView`, `List`, `ScrollView`) "adapt to the fold for free". |
| [9:20](https://developer.apple.com/videos/play/tech-talks/111463/?time=560) | Arrangement = a function from inputs (horizontal and vertical size class, aspect ratio, active division regions) to outputs (whether each view is visible, and its frame). |
| [11:17](https://developer.apple.com/videos/play/tech-talks/111463/?time=677) | `ArrangementView { Primary } secondary: { Secondary }` inside `NavigationStack`. UIKit: `UIArrangementViewController.setViewController(_:for:)`. |
| [12:00](https://developer.apple.com/videos/play/tech-talks/111463/?time=720) | `.split` (the default) splits horizontally when wider than tall and vertically when taller than wide. With `.split.axes(.horizontal)`, if it can't split along the primary axis it **shows only the primary view**. |
| [13:21](https://developer.apple.com/videos/play/tech-talks/111463/?time=801) | `.overlay` prefers stacking the views in z-order. **When folded, it places them side by side.** `@Environment(\.overlayArrangementZIndex)` changes as the device folds, e.g. to switch between collapsed and expanded UI. UIKit: `state(for: .primary)?.zIndex`. |
| [14:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=879) | Choosing: `HStack`/`VStack` → split, `ZStack` → overlay. Foreground/background relationship → overlay. Main/detail where neither view may be obscured → split. |
| [16:09](https://developer.apple.com/videos/play/tech-talks/111463/?time=969) | **Don't** put `NavigationSplitView` inside an `ArrangementView`. **Don't** put an `ArrangementView` inside a `List` or `ScrollView`. |
| [16:34](https://developer.apple.com/videos/play/tech-talks/111463/?time=994) | Next steps: audit centered layouts, adopt `ArrangementView` for custom split or overlay layouts, and use reserved regions for high-priority manually laid-out controls. |

## Code (from the talk)

```swift
GeometryReader { proxy in
  let regions = proxy.reservedRegions(kind: .division, options: .includeInactive)
  let frames = regions.map(\.frame)
}

ArrangementView { PlayerView() } secondary: { UpNextView() }
  .arrangementViewStyle(.split.axes(.horizontal))

struct UpNextView: View {
  @Environment(\.overlayArrangementZIndex) private var zIndex: Int
  var minimization: UpNextMinimization { zIndex > 0 ? .collapsed : .expanded }
}
```

## SDK extras not shown in the talk (iOS 27.1 swiftinterface)
- `ReservedRegion` has `id`, `kind`, `frame`, **`margins: EdgeInsets`**, `isActive`. The UIKit header says `frame` includes the margins "around the reserved rect for interactive content".
- `reservedRegions(kind:options:layoutDirectionBehavior: = .mirrors)` mirrors regions automatically for RTL. Pass `.fixed` to get raw hardware coordinates.
- Split tuning: `splitArrangementLayoutRatio(_:)`, `splitArrangementLayoutRatio(minHorizontal:idealHorizontal:…)`, `splitArrangementLayoutSize(minWidth:…)`, `splitArrangementFixedLayoutSize(horizontal:vertical:)`, `@Environment(\.splitArrangementAxis)`.
- Overlay tuning: `overlayArrangementEdge(_: VerticalEdge?)` and `overlayArrangementEdge(_: HorizontalEdge?)`.
- Styles: `.automatic` (resolves to split), `.split`, `.overlay`, each with `.axes(_:)`.

## Related experiments
[02 player arrangement](../../research/02-player-arrangement.md) · [03 custom popup](../../research/03-custom-popup.md)
