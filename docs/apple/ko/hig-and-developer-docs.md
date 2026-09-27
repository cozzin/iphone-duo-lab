# HIG "Designing for iPhone Duo" + 개발 문서 "Preparing your app for iPhone Duo"

- HIG: https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo (2026-09-09 신설)
- 개발 문서: https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo
- 확인일: 2026-09-28

## HIG 핵심

**자세와 size class**
- > "A compact width layout for the outer display and a regular width layout for the inner display give you the fundamentals for every pose."

  외부 화면은 compact, 내부 화면은 regular 두 가지만 있으면 모든 자세의 기본은 충족됩니다. 자세마다 레이아웃을 새로 만들지 말고, 기존 레이아웃이 공간에 맞게 늘어나게 하라고 합니다.
- > "Avoid fixed widths and display-specific dependencies."

  고정 폭과 특정 화면에 의존하는 값을 피하라는 뜻입니다.
- 게임은 portrait나 landscape로 고정해도 되지만, 자세가 바뀌면 화면을 채워야 합니다. 레터박스보다는 비율을 바꾸는 쪽이 낫다고 합니다.

**하드웨어 구조**
- 외부 전면 카메라는 **모서리**에 있고 항상 보이며, 측면 컨트롤과 세로로 정렬됩니다.
- 내부 카메라는 디스플레이 뒤에 숨어 있다가 카메라를 켤 때만 드러납니다.

**Reserved region**
- **외부 카메라**: 항상 존재하며, Live Activity가 오면 Dynamic Island로 확장됩니다. 컨트롤이 측면에 있으면 시스템이 자동으로 이 영역을 감안해 배치합니다.
- **내부 카메라**: 카메라를 쓰는 동안에만 존재합니다.
- **폴딩 영역**: partially open일 때 내부 화면을 여러 영역으로 나누고, 가운데 부분은 사용 영역에서 제외합니다.
- alert, context menu, sheet는 자동으로 힌지를 피합니다. **커스텀 컴포넌트는 `ReservedRegion` API로 직접 위치를 옮겨야 합니다.**
- 그리드는 짝수 열을 권장합니다. 접을 때 레이아웃을 크게 바꾸지 말고 필요한 것만 옮기라고 합니다.

**Arrangement view**
- split은 가로가 길면 좌우로, 세로가 길면 위아래로 나눕니다.
- overlay는 반쯤 접으면 양쪽으로 나뉘고, 그 외에는 primary가 secondary 위에 겹쳐집니다.
- 내비게이션 컨테이너는 arrangement view의 바깥에 둡니다.

**세로 컨트롤**
- 내부 화면 세로 방향만 가로 바를 유지합니다.
- 측면 세로 열에는 **Dynamic Island, status bar, 툴바, 탭바**가 함께 들어갑니다.
- Split View에서는 두 앱이 각자 화면 바깥쪽 가장자리에 컨트롤을 둡니다. 즉 왼쪽 앱은 컨트롤이 왼쪽에 옵니다.
- **레이아웃의 비대칭을 고려**해야 합니다.
- > "Consider using the full display width for interfaces where bars aren't necessary … **as long as nothing conflicts with the Dynamic Island or the status bar.**"

  바가 필요 없는 UI는 전체 폭을 써도 되지만, Dynamic Island나 status bar와 겹치지 않아야 합니다. 배경이나 헤더는 전체 폭으로, 스크롤 콘텐츠는 inset으로 섞는 방식도 권장합니다.
- 기본 바 배치를 임의로 바꾸지 말라고 합니다.

## 개발 문서 핵심
- Xcode 26 이하로 빌드하면 앱이 status bar와 카메라 아래까지 확장되지 않습니다.
- 뷰 크기는 컨테이너 기준으로, 계산은 scene이나 상위 뷰의 bounds 기준으로 합니다. idiom이나 `UIInterfaceOrientation`으로 레이아웃을 결정하지 않습니다.
- **Overlay arrangement의 partially open 배치**: primary는 trailing 또는 아래쪽, secondary는 leading 또는 위쪽입니다.
- 히어로나 배경 이미지는 SwiftUI의 `backgroundExtensionEffect()`나 UIKit의 `UIBackgroundExtensionView`로 세로 바 아래까지 확장합니다.
- 외부 전면 카메라는 **항상** 뷰를 가리고, 내부 카메라는 활성화됐을 때만 가립니다.

## API 레퍼런스 메모
- `ArrangementView`의 기본 스타일 `.automatic`은 split으로 동작합니다. overlay 예시는 primary=`PlayerControls`, secondary=`VideoPlayer`이며, 문서는 이것을 "재생 컨트롤이 비디오 표면 위에 겹치는 전체 화면 경험"에 적합하다고 설명합니다.
- `ReservedRegion` 문서는 "활성 여부와 관계없이 교차하는 모든 영역을 반환한다"고 하지만, Tech Talk에서는 "기본은 활성 영역만 반환"이라고 합니다. 두 설명이 **상충하므로 실험으로 확인이 필요합니다**.
