# Modernize your UIKit app (WWDC26 session 278)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/wwdc2026/278/ |
| Length | ~16 min |
| Accessed | 2026-09-28 |

## TL;DR
- iOS 27 makes iPhone apps **resizable** (iPhone Mirroring, and iPhone Duo). **The UIScene lifecycle is required** with the latest SDK.
- **Supported interface orientations are only a preference, and the system ignores them in resizable environments.** `UIRequiresFullScreen` now means *discrete* resizing rather than opting out.
- Stop using `UIScreen.main`, idiom, and interface orientation for layout. Use traits, scene geometry, and view bounds instead.

## Key points (timestamped)

| Time | Point |
|------|-------|
| 0:34 | App adaptivity: "it is important that your app dynamically adjusts to any available scene size at runtime." |
| [2:10](https://developer.apple.com/videos/play/wwdc2026/278/?time=130) | "UIScene lifecycle is now required when building with the latest SDKs. Without it, your application will no longer launch." |
| [2:51](https://developer.apple.com/videos/play/wwdc2026/278/?time=171) | Don't reference the main screen. Use `window?.windowScene?.screen` and `traitCollection.displayScale`, and register for trait changes. `windowScene(_:didUpdateEffectiveGeometry:)` reports changes to the scene's effective geometry. |
| [5:46](https://developer.apple.com/videos/play/wwdc2026/278/?time=346) | "UIRequiresFullscreen is honored on iPhone in resizable environments starting in iOS 27. Its behavior has also been updated and **no longer opts your app fully out of resizing. Instead, it enables discrete resizing that honors your supported interface orientations.**" |
| [6:17](https://developer.apple.com/videos/play/wwdc2026/278/?time=377) | Idiom "is no longer meaningful for any kind of layout decision". |
| [6:50](https://developer.apple.com/videos/play/wwdc2026/278/?time=410) | "**In iOS 27, an app's supported interface orientation is a preference provided to the system. It will be ignored when your app is running in a resizable environment.**" In iPhone Mirroring, apps always run in portrait interface orientation regardless of aspect ratio. "Any interface orientation checks in your app should also be updated to use size classes." |
| [8:19](https://developer.apple.com/videos/play/wwdc2026/278/?time=499) | Test your resizable iPhone app. |
| 9:18–12:37 | Tab bars and sidebars (`sidebar.preferredPlacement = .sidebar`), navigation bar minimization, menus. |
| [14:07](https://developer.apple.com/videos/play/wwdc2026/278/?time=847) | Xcode's agent skill for app modernization. `xcrun agent skills export` exports skills as Markdown. |

## Code (from the session)

```swift
func windowScene(_ windowScene: UIWindowScene,
                 didUpdateEffectiveGeometry previous: UIWindowScene.Geometry) {
  let availableSpace = windowScene.effectiveGeometry.coordinateSpace.bounds
}
registerForTraitChanges([UITraitDisplayScale.self]) { (view: GalleryView, _) in view.cache.invalidate() }
```

## Related experiments
[05 PiP / portrait-only](../../research/05-pip-resize.md) · [01 size class](../../research/01-size-class.md)
