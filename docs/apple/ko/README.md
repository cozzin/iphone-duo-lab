# Apple iPhone Duo 자료 정리 (한국어)

Apple의 iPhone Duo 관련 세션과 문서를 근거 자료로 인용할 수 있게 정리했습니다. 원문 인용은 정확성을 위해 **영어 그대로** 두고, 그 아래에 한국어로 해설을 붙였습니다. 타임스탬프 링크를 누르면 영상의 해당 시점으로 바로 이동합니다.

| 노트 | 내용 |
|------|------|
| [111461 Prepare your app](111461-prepare-your-app.md) | SDK, size class, 방향, safe area |
| [111462 Raise the bar](111462-raise-the-bar.md) | 세로(vertical) 바 |
| [111463 Strike a pose](111463-strike-a-pose.md) | Reserved region, ArrangementView |
| [111464 Multiple displays and scenes](111464-multiple-displays-and-scenes.md) | 힌지 API, 멀티태스킹, scene |
| [111466 Design for iPhone Duo](111466-design-for-iphone-duo.md) | 디자인 원칙, PiP, 힌지 회피 |
| [WWDC26-278 Modernize your UIKit app](wwdc26-278-modernize-uikit.md) | 리사이즈 가능한 iPhone 앱, 방향, UIRequiresFullScreen |
| [HIG + 개발자 문서](hig-and-developer-docs.md) | HIG 페이지, 개요 아티클, API 레퍼런스 |

## 핵심 사실 요약

출처 ID는 [sources.md](../../sources.md)를 참고하세요.

| 사실 | 출처 |
|------|------|
| 외부 화면은 compact width입니다(세로 C/R, 가로 C/C). 내부 화면은 regular/regular입니다. | S1 2:46, D1 |
| 외부 화면은 466×678pt, 내부 화면은 669×951pt입니다(3x 기준). | M1(직접 측정), T3 |
| 레이아웃은 compact(외부)와 regular(내부) 두 가지만 설계합니다. Apple은 breakpoint를 쓰지 말라고 명시합니다. | S6 3:42, D1 |
| 내부 화면은 supported interface orientations를 따르지 않습니다. iOS 27부터는 리사이즈 환경에서 이 값이 "선호(preference)"일 뿐입니다. | S1 2:46, S7 6:50, T1 |
| 내비게이션 바·툴바·탭바가 측면 세로 바로 이동합니다. Dynamic Island와 status bar도 같은 세로 열을 씁니다. 예외는 내부 화면 세로 방향뿐입니다. | S2, S6 0:28, D1 |
| Safe area는 좌우 비대칭입니다. | S1 7:30, D1 |
| 배경은 화면 끝까지 채우고, 컨트롤은 safe area 안에 둡니다. 전체 폭을 쓰는 것은 Dynamic Island나 status bar와 겹치지 않을 때만 괜찮습니다. | S1, S6 6:33, D1 |
| 시스템 alert·sheet·menu·popover는 힌지를 자동으로 피합니다. 커스텀 UI는 `ReservedRegion`으로 직접 처리해야 합니다. | S3 5:12, S6 9:28, D1 |
| 힌지 API는 효과·인터랙션용입니다. 레이아웃 결정에는 쓰지 않습니다. | S4 2:35 |
| PiP를 화면 상단에 고정할 수 있고, 그러면 앱은 세로 방향으로 리사이즈됩니다. | S4 2:59, S6 ~1:40 |
| Overlay arrangement는 partially open일 때 primary를 trailing/하단에, secondary를 leading/상단에 배치합니다. | D2 |

English: [../en](../en/README.md)
