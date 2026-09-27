# Raise the bar with iPhone Duo (Tech Talk 111462)

- URL: https://developer.apple.com/videos/play/tech-talks/111462/
- 길이: 약 15분
- 발표: Anna (UI Frameworks), Maria (HI Designer)
- 확인일: 2026-09-28

## 세 줄 요약
- 외부 화면과 내부 화면 가로 방향에서는 **내비게이션 바·툴바·탭바가 측면 세로 바로 이동**합니다. 같은 세로 열에 status bar와 Dynamic Island도 함께 있습니다.
- 이 동작을 적용받으려면 **시스템 컨테이너**를 써야 합니다. 직접 만든 `UIToolbar`나 `UITabBar`는 세로 바에 참여하지 않습니다.
- 각 아이템에 심볼과 제목을 모두 지정합니다. 배치는 `axisBehavior`, `visibilityPriority`, `toolbarVerticalCompressionBehavior`로 조정합니다. 세로 바를 끄는 `toolbarVerticalBehavior(.disabled)`는 가로 바가 더 적합한 경우에만 씁니다.

## 핵심 내용

| 시점 | 내용 |
|------|------|
| 0:28 | 외부 화면은 넓고 낮아서, 바를 옆으로 옮기면 세로 공간을 확보하고 손이 닿기도 쉬워집니다. |
| 2:00 | 최신 SDK로 빌드하고 시스템 컨테이너를 쓰면 자동으로 적용됩니다. |
| 4:29 | 순서: 맨 위에는 Back/Close 같은 1차 내비게이션을, 그 다음에 Done 같은 주요 액션을 둡니다. SwiftUI는 `.cancellationAction`/`.topBarPinnedTrailing`, UIKit은 `leadingItemGroups`/`pinnedTrailingGroup`을 씁니다. |
| 5:56 | 세로 바는 폭이 고정되어 있으므로 심볼만 있는 아이템이 적합합니다. 텍스트 대신 badge를 활용합니다. |
| 8:00 | `axisBehavior(.verticalPreferred)`는 커스텀 뷰를 세로 바에 허용하고, `.horizontalOnly`는 가로 바에만 둡니다. |
| 10:07 | 커스텀 뷰는 `@Environment(\.toolbarVerticalEdge)` 또는 `traitCollection.verticalBarEdge`로 세로 바가 있는지 알 수 있습니다. |
| 11:40 | 공간이 부족할 때 무엇을 먼저 접을지 `toolbarVerticalCompressionBehavior(.prefersToolbarItems / .prefersTabBar)`로 정합니다. 기본값은 툴바 아이템이 먼저 overflow로 들어가는 것입니다. |
| 13:10 | overflow 순서는 `visibilityPriority`로 조정합니다. |
| 14:21 | 세로 바를 끄려면 `toolbarVerticalBehavior(.disabled)` 또는 `preferredVerticalBarBehavior = .disabled`를 씁니다. 계산기처럼 한 화면짜리 UI나 닫기 버튼만 있는 sheet에 적합합니다. |

## 추가 규칙 (발표와 D2 문서)
- **Split view**: 세로 바는 detail(trailing) 열에만 붙습니다.
- **Inspector**: 가로 바를 씁니다.
- **Sheet**: 외부 화면에서는 세로 바입니다. 내부 화면에서는 가운데나 leading 배치일 때 가로, trailing 배치일 때 세로입니다.
- **RTL 언어**: 세로 바는 하드웨어 기준으로 같은 쪽에 그대로 있습니다.

## 헤더 주석 (UIViewController.h, 원문)
> "Disable the vertical bar only for UIs that are better served by horizontal bars, such as a fullscreen video player with toolbar controls or a non-scrolling layout like a calculator. Treat it as a stable choice … the leading or trailing safe area inset for the vertical bar is added or removed."

즉 세로 바를 켜거나 끄면 **leading/trailing safe area inset이 생기거나 사라집니다**. 이 점은 실험 07의 근거입니다.
