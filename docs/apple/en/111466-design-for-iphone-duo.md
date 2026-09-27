# Design for iPhone Duo (Tech Talk 111466)

| | |
|---|---|
| URL | https://developer.apple.com/videos/play/tech-talks/111466/ |
| Length | ~10 min |
| Speakers | Marcos, Vince (Apple Design) |
| Accessed | 2026-09-28 |

## TL;DR
- Don't design a layout for every pose. **Design two: compact width (outer) and regular width (inner). "Avoid fixed widths, breakpoints, or any metrics tied to a specific screen."**
- Controls move to the **right-side vertical bar**, which the Dynamic Island and status bar also use. Content is offset by the safe area. Immersive, non-scrolling UIs may use the full display, and a **full-width background with inset scrollable content** is fine.
- When partially folded, system components **nudge interactive elements away from the fold**. On a table, **media sits at the top and tappable controls at the bottom**. **A pinned PiP resizes your app vertically.**

## Key points (timestamped)

| Time | Point |
|------|-------|
| 0:28 | "This new space on the side houses the app controls. This includes the tab bar, the app toolbars, and navigation controls like the back button, the new redesigned status bar, and **the Dynamic Island, which expands vertically as Live Activities arrive**." |
| ~1:30 | Poses: closed, open, partially folded like a book, seated like a laptop, standing on its edges. "The same goes for portrait orientation." |
| ~1:40–2:00 | Split View is a 50/50 split built on the home gesture. **PiP:** "And when a video is playing in picture-in-picture, you can now pin it to the top of the screen to keep watching it. Your current app resizes vertically to fit the space that's left. And if you partially fold the device, the video extends to fill half of the screen. So apps adjust vertically to the different video sizes in real time." |
| [3:42](https://developer.apple.com/videos/play/tech-talks/111466/?time=222) | "…focus on two size classes: compact width on the outer display and regular width on the inner display. **Avoid fixed widths, breakpoints, or any metrics tied to a specific screen.**" Build with layout margins and horizontal safe area insets, and "design your app to be freely resizable". |
| [5:07](https://developer.apple.com/videos/play/tech-talks/111466/?time=307) | Top toolbar buttons go to the top of the side bar, bottom ones to the bottom, and the tab bar is bottom-aligned. Items that are too wide (text buttons, segmented controls) stay in the nav bar. "The only pose where we've kept horizontal bars is on the inner display in portrait." |
| [6:33](https://developer.apple.com/videos/play/tech-talks/111466/?time=393) | Outer display: "most content needs an offset so it isn't hidden behind controls. Safe area insets provide this … Immersive, highly visual interfaces that don't scroll may still benefit from centering on the full display. **You can also mix both approaches, a full-width background image or header with scrollable foreground content that's inset.**" |
| [7:34](https://developer.apple.com/videos/play/tech-talks/111466/?time=454) | Inner display: show more content with split views or a two-column layout. |
| [8:36](https://developer.apple.com/videos/play/tech-talks/111466/?time=516) | Sheets: vertical controls on the outer display, horizontal bars on the inner display. "When the device is folded, sheets slide over to avoid resting in the fold." A sheet with a single button can disable its vertical bar. |
| [9:28](https://developer.apple.com/videos/play/tech-talks/111466/?time=568) | Fold avoidance: "We found buttons are tough to tap when they land right in the fold … a behavior that nudges interactive elements aside … built into … sheets, alerts, menus, toolbar buttons, and more." "**Except for scrollable content, keep interactive elements away from the hinge as much as possible.**" When partially folded like a laptop, "interactive elements move to the bottom half … **Media can sit at the top, while tappable controls live on a stable base at the bottom.**" |

> Note: the timestamps without links were estimated from the transcript by the web tool and may be off by a few seconds.

## Related experiments
[01 / 01-b size class & breakpoints](../../research/01b-breakpoint-vs-size-class.md) · [02 player](../../research/02-player-arrangement.md) · [03 popup](../../research/03-custom-popup.md) · [05 PiP](../../research/05-pip-resize.md) · [07 safe area](../../research/07-safe-area-dynamic-island.md)
