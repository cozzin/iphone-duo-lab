# Design for iPhone Duo (Tech Talk 111466)

- URL: https://developer.apple.com/videos/play/tech-talks/111466/
- 길이: 약 10분
- 발표: Marcos, Vince (Apple Design)
- 확인일: 2026-09-28

## 세 줄 요약
- 자세마다 레이아웃을 따로 설계하지 말고, **compact(외부)와 regular(내부) 두 가지만** 설계합니다. **"Avoid fixed widths, breakpoints, or any metrics tied to a specific screen."**
- 컨트롤은 **오른쪽 세로 바**로 이동하며, 여기에 Dynamic Island와 status bar가 함께 있습니다. 콘텐츠는 safe area만큼 안쪽으로 들어가고, **배경은 전체 폭 + 스크롤 콘텐츠는 inset**으로 섞는 방식도 괜찮습니다.
- 반쯤 접으면 시스템 컴포넌트가 **인터랙티브 요소를 힌지에서 밀어냅니다**. 테이블에 놓은 자세에서는 **미디어는 위, 컨트롤은 아래**에 둡니다. **PiP를 상단에 고정하면 앱은 세로로 리사이즈됩니다.**

## 핵심 내용

| 시점 | 내용 |
|------|------|
| 0:28 | 측면 공간에는 탭바, 툴바, 뒤로가기 버튼, 새 status bar, 그리고 **Live Activity가 오면 세로로 늘어나는 Dynamic Island**가 들어갑니다. |
| ~1:40–2:00 | **PiP**: "you can now pin it to the top of the screen … Your current app resizes vertically to fit the space that's left. And if you partially fold the device, the video extends to fill half of the screen." 즉 PiP를 위에 고정하면 앱은 남은 공간으로 세로 리사이즈되고, 반쯤 접으면 비디오가 화면 절반을 차지합니다. |
| [3:42](https://developer.apple.com/videos/play/tech-talks/111466/?time=222) | "focus on two size classes: compact width on the outer display and regular width on the inner display. **Avoid fixed widths, breakpoints, or any metrics tied to a specific screen.**" layout margin과 가로 safe area inset으로 만들고, "자유롭게 리사이즈되는 앱"을 목표로 하라고 합니다. |
| [5:07](https://developer.apple.com/videos/play/tech-talks/111466/?time=307) | 상단 툴바 버튼은 세로 바의 위쪽, 하단 버튼은 아래쪽으로 가고, 탭바는 아래에 정렬됩니다. 텍스트 버튼이나 segmented control처럼 폭이 넓은 아이템은 nav bar에 그대로 남습니다. 가로 바가 유지되는 자세는 **내부 화면 세로 방향뿐**입니다. |
| [6:33](https://developer.apple.com/videos/play/tech-talks/111466/?time=393) | 외부 화면에서는 대부분의 콘텐츠가 컨트롤에 가리지 않도록 inset이 필요합니다. 스크롤하지 않는 몰입형 UI는 전체 화면 가운데 정렬도 괜찮습니다. **"a full-width background image or header with scrollable foreground content that's inset"**처럼 두 방식을 섞어도 됩니다. |
| [8:36](https://developer.apple.com/videos/play/tech-talks/111466/?time=516) | sheet는 외부 화면에서 세로 컨트롤, 내부 화면에서 가로 바를 씁니다. **기기를 접으면 sheet가 옆으로 밀려서 힌지를 피합니다.** |
| [9:28](https://developer.apple.com/videos/play/tech-talks/111466/?time=568) | 힌지 위에 있는 버튼은 누르기 어려워서, sheet·alert·menu·toolbar 버튼 등 시스템 컴포넌트에 **인터랙티브 요소를 힌지 옆으로 밀어내는 동작**이 내장되어 있습니다. **"Except for scrollable content, keep interactive elements away from the hinge as much as possible."** 랩톱처럼 놓으면 인터랙티브 요소는 아래 절반으로 갑니다. **"Media can sit at the top, while tappable controls live on a stable base at the bottom."** |

> 링크가 없는 타임스탬프는 스크립트를 보고 추정한 값이라 몇 초 정도 차이가 날 수 있습니다.
