# Raise the bar with iPhone Duo (Tech Talk 111462)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/tech-talks/111462/ |
| Length | ~15 min |
| Speakers | Anna (UI Frameworks), Maria (Human Interface Designer) |
| Accessed | 2026-09-28 |

## TL;DR
- On the outer display, and on the inner display in landscape, the **navigation bar, toolbar, and tab bar move into a vertical bar on the side**. The status bar and Dynamic Island share that column.
- You opt in by using **system containers** (`NavigationStack`/`TabView`, `UINavigationController`/`UITabBarController`). Standalone `UIToolbar`/`UITabBar` instances don't participate.
- Give each item both a symbol and a title, use `axisBehavior`, `visibilityPriority`, and `toolbarVerticalCompressionBehavior` to control placement, and opt out with `toolbarVerticalBehavior(.disabled)` only when horizontal bars clearly work better.

## Key points (timestamped)

| Time | Point |
|------|-------|
| 0:28 | Why bars move to the side: the outer display is wide and short, so moving bars preserves vertical space and improves reach. |
| 2:00 | Opt in by rebuilding against the latest SDK and using system containers. |
| 3:09 | The navigation bar, toolbar, and tab bar share one vertical bar region. |
| 4:29 | Ordering: the top is for primary navigation (Back/Close), then prominent actions (Done). Use `.cancellationAction` and `.topBarPinnedTrailing` in SwiftUI, or `leadingItemGroups` and `pinnedTrailingGroup` in UIKit. |
| 5:56 | The vertical bar has a fixed width and flexible item height, so symbol-only items fit best. Use badges instead of inline text. |
| 8:00 | `axisBehavior(.verticalPreferred)` lets a custom view go vertical. `.horizontalOnly` keeps an item in a horizontal bar. |
| 10:07 | Custom views can detect the vertical bar with `@Environment(\.toolbarVerticalEdge)` in SwiftUI or `traitCollection.verticalBarEdge` in UIKit. |
| 11:40 | When space runs out, `toolbarVerticalCompressionBehavior(.prefersToolbarItems / .prefersTabBar)` chooses which set compresses first. By default, toolbar items overflow first. |
| 13:10 | `visibilityPriority(.high/.low)` sets the overflow order. |
| 14:21 | Opt out with `toolbarVerticalBehavior(.disabled)` in SwiftUI or `preferredVerticalBarBehavior = .disabled` in UIKit. Suitable cases: single-page, bottom-heavy UIs such as Calculator, and sheets that have only a Close button. |

Additional rules from the talk and D2:
- **Split views:** only the detail (trailing) column gets the vertical bar.
- **Inspectors:** horizontal bars.
- **Sheets:** vertical on the outer display. On the inner display, horizontal when centered or leading and vertical when trailing (`presentationPlacement`).
- **RTL:** the bar stays on the same *hardware* side.

## SDK signatures (iOS 27.1, from the swiftinterface / headers)

```swift
// SwiftUI
func toolbarVerticalBehavior(_: ToolbarVerticalBehavior) -> some View              // .automatic, .disabled
func toolbarVerticalCompressionBehavior(_: ToolbarVerticalCompressionBehavior)      // .automatic, .prefersToolbarItems, .prefersTabBar
extension ToolbarContent { func axisBehavior(_: ToolbarItemAxisBehavior) }         // .automatic, (.horizontalOnly, .verticalPreferred)
extension EnvironmentValues { var toolbarVerticalEdge: HorizontalEdge? }
// UIKit
UIViewController.preferredVerticalBarBehavior: UIVerticalBarBehavior               // .automatic, .disabled
UIViewController.setNeedsUpdateOfVerticalBarConfiguration()
UITraitCollection.verticalBarEdge: UIVerticalBarEdge                              // .unspecified, .leading, .trailing
UINavigationItem.verticalBarCompressionBehavior
UIBarButtonItem.axisBehavior
```

From the header comment on `preferredVerticalBarBehavior`: *"Disable the vertical bar only for UIs that are better served by horizontal bars, such as a fullscreen video player with toolbar controls or a non-scrolling layout like a calculator. Treat it as a stable choice … When the resolved configuration changes … the leading or trailing safe area inset for the vertical bar is added or removed."*

## Related experiments
[07 safe area / Dynamic Island](../../research/07-safe-area-dynamic-island.md)
