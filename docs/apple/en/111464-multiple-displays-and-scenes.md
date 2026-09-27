# Leverage multiple displays and scenes on iPhone Duo (Tech Talk 111464)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/tech-talks/111464/ |
| Length | ~7 min |
| Speakers | Chris Donegan (Engineering Manager, UI Frameworks), Alex Muller (System Experience) |
| Accessed | 2026-09-28 |

## TL;DR
- `onHingeChange` / `UIHingeInteraction` report the hinge **status** (closed / partially open / fully open) and a continuous **angle**. **Use them for interactions and effects, not layout.**
- **All apps take part in Split View multitasking.** iPhone Duo also has a **new layout that stacks video and apps together** (PiP pinned to the top). Handle both layouts the same way.
- iPhone Duo is the first iPhone that supports multiple scenes, but **new windows can only be created on the inner display**. Camera apps can use `CameraCaptureAccessory` to show content on the outer display.

## Key points (timestamped)

| Time | Point |
|------|-------|
| [0:49](https://developer.apple.com/videos/play/tech-talks/111464/?time=49) | Hinge APIs: SwiftUI `onHingeChange`, UIKit `UIHingeInteraction`. |
| [1:18](https://developer.apple.com/videos/play/tech-talks/111464/?time=78) | Example: a guitar app that maps the hinge angle to a whammy-bar pitch bend, but only while `.partiallyOpen`. A `nil` hinge means the device doesn't have one. |
| [2:35](https://developer.apple.com/videos/play/tech-talks/111464/?time=155) | "**Hinge data is observed live, and is ideal for driving interactions or effects. For layout, use the arrangement and region APIs.**" |
| [2:59](https://developer.apple.com/videos/play/tech-talks/111464/?time=179) | "All apps participate in multitasking on iPhone Duo, where two apps can be placed in a side-by-side layout. If your app already supports resizing on iPad or iPhone Mirroring, you're off to a great start. **iPhone Duo has a completely new layout, stacking video and apps together. Your app handles both of these layouts the same.** The system … provides tools like size classes and scene geometry to use in your layout decisions." |
| [3:38](https://developer.apple.com/videos/play/tech-talks/111464/?time=218) | Multiple scenes: apps that support them on iPad support them on iPhone Duo automatically. "New windows can only be created on the inner display." Handle scene-request errors. `UIWindowSceneActivationAction` hides itself automatically when new windows aren't available. |
| [4:22](https://developer.apple.com/videos/play/tech-talks/111464/?time=262) | Scene accessories show content on multiple displays. The system controls their availability. |
| [5:00](https://developer.apple.com/videos/play/tech-talks/111464/?time=300) | `CameraCaptureAccessory` shows UI on the outer display while the camera UI is on the inner display. It requires the app to be full screen on the inner display with an active camera session. |

## Code (from the talk)

```swift
GuitarView(pitchBend: pitchBend)
  .onHingeChange { _, context in
    // A null hinge means the device doesn't have one
    if let hinge = context.hinge, hinge.status == .partiallyOpen {
      pitchBend = calculatePitchBend(angle: hinge.angle)   // hinge.angle: Angle
    } else {
      pitchBend = 0
    }
  }
```

## SDK signatures (iOS 27.1)

```swift
// SwiftUI
func onHingeChange(isEnabled: Bool = true,
                   _ action: @escaping (_ oldContext: DeviceHingeContext, _ newContext: DeviceHingeContext) -> Void) -> some View
struct DeviceHingeContext { var hinge: DeviceHinge? }
struct DeviceHinge { var status: Status; var angle: Angle }   // Status: .closed, .partiallyOpen, .fullyOpen
// UIKit
UIHingeInteraction(updateHandler: (UIHingeInteraction, UIHingeInteraction.Update) -> Void)  // update.hinge: UIHinge?
UIHinge.status: UIHinge.Status   // .unknown, .closed, .partiallyOpen, .fullyOpen
UIHinge.angle: CGFloat           // radians
UIHingeInteraction.isEnabled     // while disabled, updates are not queued
```

The header says: *"The rate and granularity of angle updates are system policy … don't depend on a particular update frequency or precision. If you only need to know whether the hinge is closed, partially open, or fully open, prefer `status` over the angle."*

## Related experiments
[04 hinge](../../research/04-hinge.md) · [05 PiP / resize](../../research/05-pip-resize.md)
