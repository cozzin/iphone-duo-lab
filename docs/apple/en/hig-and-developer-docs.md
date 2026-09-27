# HIG "Designing for iPhone Duo" + article "Preparing your app for iPhone Duo"

| | |
|---|---|
| HIG | https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo (new page, 2026-09-09) |
| Article | https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo |
| Accessed | 2026-09-28 |

## HIG, key statements (quoted)

**Poses and size classes**
- "Supporting the device's various poses doesn't mean designing a custom layout for each one: instead, use Size classes so your app adapts naturally as it changes size. **A compact width layout for the outer display and a regular width layout for the inner display give you the fundamentals for every pose.** Don't reinvent your app when it resizes; allow the existing layout to expand based on the available space instead."
- "**Build your app to resize.** … Use size classes, layout margins, and safe area insets to lay out controls and content. **Avoid fixed widths and display-specific dependencies.**"
- "**Maintain the same functionality across device poses.**"
- Games: "You can choose to lock to either portrait or landscape orientation, but be sure to fill the screen as the device pose changes … Prefer changing the aspect ratio over letterboxing or pillarboxing."

**Anatomy**
- "The outer front-facing camera is in the corner and is always visible, vertically aligned with controls on the side. The inner camera is behind the display and stays hidden until the camera is active."

**Reserved regions**
- "**The outer front-facing camera.** This region is always present, and expands into the Dynamic Island for Live Activities. When controls are on the side, the system automatically accounts for it and arranges elements accordingly."
- "**The inner front-facing camera.** This region is only present when the camera is active …"
- "**The folding region.** … When the device is partially open, the folding region divides the inner display into multiple usable regions, excluding the region at the center as the display folds."
- "Components like alerts, context menus, and sheets automatically move to account for the fold, while larger components like Split views adapt their columns' width and margins … **For custom components, ReservedRegion (SwiftUI) and UIView.ReservedRegion (UIKit) provide a way to reposition content away from reserved regions.**"
- "In a grid-style layout, prefer an even number of columns so content divides cleanly."
- "**Avoid extreme layout changes as people fold the device.** Move only what's necessary …"

**Arrangement views**
- Split: splits horizontally when wider than tall and vertically when taller than wide.
- Overlay: "When the display is partially folded, the views move to occupy each side; otherwise the primary view moves atop the secondary view."
- "Keep navigation outside of arrangement views."

**Vertical controls**
- "The exception is the inner display in portrait, which has enough vertical space to keep standard horizontal bars."
- "Controls on the side include both system and app elements: the Dynamic Island, the status bar, the toolbar (including navigation buttons), and the tab bar."
- "When two apps share the inner display with Split View multitasking, each one places controls along its outer edge, so the left app has controls on the left."
- "**Account for asymmetry in your layouts.**"
- "**Consider using the full display width for interfaces where bars aren't necessary.** Some layouts can span the full display … **as long as nothing conflicts with the Dynamic Island or the status bar.** … You can also combine both approaches, letting a background image or header span the full width while scrollable content stays inset."
- "**In general, don't override the default bar placement.**"

## Developer article, key statements (quoted)
- "Build your app with the latest version of Xcode to use all of the available screen space on iPhone Duo. When you build with Xcode 26 and earlier, your app doesn't extend under the status bar and camera."
- Checklist: "Size your views relative to their container rather than to fixed iPhone dimensions." "Make layout calculations based on your scene or containing view's bounds rather than screen dimensions." "Don't use userInterfaceIdiom or UIInterfaceOrientation for layout decisions."
- **Overlay arrangement placement:** "When iPhone Duo is partially open, the overlay arrangement places the **primary view in the trailing or bottom part** of the display relative to the fold, and the **secondary view in the leading or top part**."
- "Avoid placing an arrangement view inside a navigation split view, list, scroll view, or other container that might cause part of your view to become inaccessible."
- "If your view has a hero or background image, extend it under a vertical bar using **`backgroundExtensionEffect()`** in SwiftUI, or `UIBackgroundExtensionView` in UIKit."
- "The inner front-facing camera can block your view when it's active, and the outer front-facing camera always occludes your view."
- Note: "A reserved region can be active or inactive. For example, a reserved region that represents the fold is active when iPhone Duo is partially open, but inactive when it is fully open."
- Sheets on the inner display: toolbar horizontal for centered or leading placement, vertical for trailing (`presentationPlacement(_:)`).

## API reference pages, notable lines
- `ArrangementView`: default style `.automatic` "resolves to a split arrangement". Overlay example: `ArrangementView { PlayerControls() } secondary: { VideoPlayer() }.arrangementViewStyle(.overlay)`, described as "well-suited for full screen experiences like media players, where playback controls overlay a video surface".
- `ReservedRegion`: "Read reserved regions using the reservedRegions(kind:options:layoutDirectionBehavior:) method, which returns all of the reserved regions that currently intersect your view **regardless of whether they are currently active**." (This conflicts with the Tech Talk; see [sources.md](../../sources.md).) Regions are mirrored for RTL by default. Pass `.fixed` to disable mirroring.
- `DeviceHinge`: "A hinge provides its angle along with a status determined by the system based on the current angle and device orientation."
