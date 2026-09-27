# Prepare your app for iPhone Duo (Tech Talk 111461)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/tech-talks/111461/ |
| Length | ~9:30 |
| Speaker | David Jackson (Engineering Manager, UI Frameworks) |
| Accessed | 2026-09-28 |

## TL;DR
- Rebuild with the **iOS 27.1 SDK**. Apps built with older SDKs keep a compatibility presentation and don't use the whole screen.
- Make layout decisions from **size classes and scene or view bounds**. Don't use idiom, interface orientation, or `UIScreen.main`.
- Keep **foreground controls inside the safe area** and let backgrounds fill the screen. Safe areas on iPhone Duo are often **asymmetric**.

## Key points (timestamped)

| Time | Point |
|------|-------|
| [0:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=30) | SDK matters. With older SDKs, "When the device is closed, your app will use the screen space to the left of the status bar and camera. When the device is open, your app will be a familiar size and aspect ratio." The iOS 27.1 SDK extends the app edge to edge and lays out bars vertically. |
| [1:17](https://developer.apple.com/videos/play/tech-talks/111461/?time=77) | Device Hub in Xcode 27.1 has control buttons to "open, close, rotate, or fold iPhone Duo". |
| [2:46](https://developer.apple.com/videos/play/tech-talks/111461/?time=166) | Size classes. Outer display: compact width + regular height in portrait, compact/compact in landscape (like other iPhones). Inner display: **regular/regular**. |
| 2:46 | "The interface orientation on the outer display behaves like any other iPhone. iPhone Duo is a great opportunity to support landscape orientation, as people may want to set the phone down like a tent." |
| 2:46 | "**The inner display doesn't honor your supported interface orientations.** As with Idiom, avoid checking interface orientation for layout decisions. Use size classes instead." |
| [3:57](https://developer.apple.com/videos/play/tech-talks/111461/?time=237) | Avoid `UIScreen.main`, which is ambiguous on a two-display device. Use `window?.windowScene?.screen` or traits instead. "iPhone Duo respects your supported interface orientations, but your app will scale on the inner display, including in Split View multitasking." |
| [4:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=270) | Use concentricity APIs (`ConcentricRectangle`, `UICornerConfiguration`) for screen-corner-aware shapes. |
| [5:01](https://developer.apple.com/videos/play/tech-talks/111461/?time=301) | "iPhone Duo will continue to honor the UIRequiresFullScreen key, but your app will still resize when someone opens or closes their iPhone Duo." `NavigationSplitView` and `UISplitViewController` adapt fully. `TabView` can opt into `.defaultTabBarPlacement(.sidebar)`. |
| [6:06](https://developer.apple.com/videos/play/tech-talks/111461/?time=366) | "Navigation bars, toolbars, and tab bars lay out outside the safe area. They automatically avoid system UI like the status bar and hardware features like the camera." Horizontal bars add top and bottom insets. Vertical bars add leading and trailing insets. |
| [6:52](https://developer.apple.com/videos/play/tech-talks/111461/?time=412) | Foreground goes inside the safe area: `foreground.frame = view.bounds.inset(by: view.safeAreaInsets)`. |
| [7:07](https://developer.apple.com/videos/play/tech-talks/111461/?time=427) | Background fills the screen: `.ignoresSafeArea()` or `backgroundView.frame = view.bounds`. |
| [7:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=450) | "Keep in mind that safe areas are often asymmetric. This is especially true on iPhone Duo. For example, vertical buttons can appear on the left side in landscape and Split View multitasking." Don't compute `width - safeAreaInsets.left * 2`. |
| [8:08](https://developer.apple.com/videos/play/tech-talks/111461/?time=488) | Reserved regions (`ReservedRegion` / `UIViewReservedRegion`) let custom UI claim space without colliding with the fold or cameras. |
| [9:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552) | Xcode 27.1 includes the updated app-modernization ("App Resizability") agent skill, which now supports SwiftUI and iPhone Duo. `UIScreen.main.scale` → `traitCollection.displayScale`. |

## Code (from the talk)

```swift
// Size classes
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass

// Screen from the scene, not UIScreen.main
let screen = window?.windowScene?.screen

// Asymmetric safe area
// AVOID: let width = view.bounds.width - view.safeAreaInsets.left * 2
let width = view.bounds.inset(by: view.safeAreaInsets).width
```

## Do / Don't
- ✅ Size classes, scene or view bounds, safe area insets, layout margins
- ✅ System navigation containers (`NavigationSplitView`, `TabView`, `NavigationStack`)
- ❌ `userInterfaceIdiom`, `UIInterfaceOrientation`, or `UIScreen.main` for layout
- ❌ Assuming the left and right insets are equal

## Related experiments
[01 size class](../../research/01-size-class.md) · [05 PiP/portrait-only](../../research/05-pip-resize.md) · [07 safe area](../../research/07-safe-area-dynamic-island.md)
