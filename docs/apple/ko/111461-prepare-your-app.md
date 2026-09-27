# Prepare your app for iPhone Duo (Tech Talk 111461)

- URL: https://developer.apple.com/videos/play/tech-talks/111461/
- 길이: 약 9분 30초
- 발표: David Jackson (UI Frameworks)
- 확인일: 2026-09-28

## 세 줄 요약
- **iOS 27.1 SDK로 다시 빌드**해야 합니다. 이전 SDK로 빌드한 앱은 호환 모드로 표시되어 화면 전체를 쓰지 못합니다.
- 레이아웃은 **size class와 scene·view의 bounds**를 기준으로 결정합니다. idiom, interface orientation, `UIScreen.main`에 의존하면 안 됩니다.
- **컨트롤 같은 전경 요소는 safe area 안**에 두고, 배경은 화면 끝까지 채웁니다. iPhone Duo의 safe area는 **좌우가 비대칭인 경우가 많습니다**.

## 핵심 내용

| 시점 | 내용 |
|------|------|
| [0:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=30) | 이전 SDK로 빌드하면 기기를 닫았을 때 앱이 "status bar와 카메라의 왼쪽 공간"만 씁니다. 열었을 때는 "익숙한 크기와 비율"로 표시됩니다. 27.1 SDK로 빌드하면 화면 끝까지 확장되고 바가 세로로 배치됩니다. |
| [1:17](https://developer.apple.com/videos/play/tech-talks/111461/?time=77) | Xcode 27.1의 Device Hub 하단 버튼으로 기기를 열고, 닫고, 회전하고, 접을 수 있습니다. |
| [2:46](https://developer.apple.com/videos/play/tech-talks/111461/?time=166) | size class 조합: 외부 화면은 세로일 때 compact width + regular height, 가로일 때 compact/compact로 일반 iPhone과 같습니다. 내부 화면은 **regular/regular**입니다. |
| 2:46 | 외부 화면의 방향은 일반 iPhone처럼 동작하며, 텐트 자세를 고려하면 가로 방향을 지원할 좋은 기회라고 설명합니다. |
| 2:46 | **"The inner display doesn't honor your supported interface orientations."** 즉 내부 화면은 앱이 지정한 지원 방향을 따르지 않습니다. 레이아웃은 방향이 아니라 size class로 판단하라고 합니다. |
| [3:57](https://developer.apple.com/videos/play/tech-talks/111461/?time=237) | 화면이 두 개인 기기에서 `UIScreen.main`은 어느 화면인지 모호하므로 `window?.windowScene?.screen`을 쓰라고 합니다. 또 "iPhone Duo respects your supported interface orientations, but your app will scale on the inner display, including in Split View multitasking."이라고 말합니다. 즉 지원 방향은 존중하지만, 내부 화면과 Split View에서는 앱이 리사이즈된다는 뜻입니다. |
| [5:01](https://developer.apple.com/videos/play/tech-talks/111461/?time=301) | `UIRequiresFullScreen` 키는 계속 존중되지만, 기기를 열고 닫을 때는 여전히 리사이즈됩니다. |
| [6:06](https://developer.apple.com/videos/play/tech-talks/111461/?time=366) | 바(bar)들은 safe area 바깥에 배치되며 status bar와 카메라를 자동으로 피합니다. 가로 바는 위/아래 inset을, 세로 바는 leading/trailing inset을 만듭니다. |
| [6:52](https://developer.apple.com/videos/play/tech-talks/111461/?time=412)–[7:07](https://developer.apple.com/videos/play/tech-talks/111461/?time=427) | 전경 요소는 safe area 안에 두고, 배경은 `.ignoresSafeArea()`로 화면 끝까지 채웁니다. |
| [7:30](https://developer.apple.com/videos/play/tech-talks/111461/?time=450) | "safe areas are often asymmetric". 예를 들어 가로 방향이나 Split View에서는 세로 버튼들이 왼쪽에 올 수도 있습니다. 좌우 inset이 같다고 가정하면 안 됩니다. |
| [8:08](https://developer.apple.com/videos/play/tech-talks/111461/?time=488) | Reserved region API로 커스텀 UI가 힌지나 카메라와 겹치지 않게 할 수 있습니다. |
| [9:12](https://developer.apple.com/videos/play/tech-talks/111461/?time=552) | Xcode 27.1에 앱 현대화(App Resizability) agent skill이 포함되며, 이제 SwiftUI와 iPhone Duo도 지원합니다. |

## 해야 할 것 / 하지 말아야 할 것
- ✅ size class, scene/view bounds, safe area inset, layout margin을 사용합니다.
- ✅ 시스템 내비게이션 컨테이너(`NavigationSplitView`, `TabView`, `NavigationStack`)를 사용합니다.
- ❌ idiom, 방향, `UIScreen.main`으로 레이아웃을 결정하지 않습니다.
- ❌ 좌우 inset이 같다고 가정하지 않습니다.
