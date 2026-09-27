# Strike a pose with adaptive layouts on iPhone Duo (Tech Talk 111463)

- URL: https://developer.apple.com/videos/play/tech-talks/111463/
- 길이: 약 17분
- 발표: Maria (HI Designer), Harry (UI Frameworks)
- 확인일: 2026-09-28

## 세 줄 요약
- 힌지와 카메라 두 개는 **reserved region**입니다. 힌지는 **division** 영역으로, 기기를 접었을 때만 활성화됩니다. 내부 카메라는 **occlusion** 영역으로, 카메라를 쓰는 동안만 활성화됩니다.
- alert, action sheet, menu, popover 같은 시스템의 가벼운 프레젠테이션은 **힌지를 자동으로 피합니다**. 커스텀 UI는 `reservedRegions(kind:)`로 영역을 조회해서 **displacement(위치 옮기기)**를 직접 구현해야 합니다.
- `ArrangementView`(split/overlay)는 뷰 두 개를 담는 레이아웃 컨테이너입니다. size class, 화면 비율, division 활성 여부에 따라 두 뷰의 배치를 자동으로 바꿉니다.

## 핵심 내용

| 시점 | 내용 |
|------|------|
| [0:27](https://developer.apple.com/videos/play/tech-talks/111463/?time=27) | reserved region은 힌지와 외부·내부 카메라입니다. iPad의 윈도우 컨트롤처럼 "이미 피해 가는 영역"과 똑같이 다루라고 합니다. |
| [1:29](https://developer.apple.com/videos/play/tech-talks/111463/?time=89) | 반쯤 접으면 화면이 가운데에서 휘어집니다(책 비유). 힌지에 걸친 콘텐츠와 컨트롤은 보기도 누르기도 어렵습니다. |
| [2:26](https://developer.apple.com/videos/play/tech-talks/111463/?time=146) | **Displacement**: 기존 요소의 frame을 조정해 보이고 닿을 수 있게 유지합니다. 과도한 이동은 피합니다. **"Continuous scrolling content like articles, feeds, documents, and lists don't displace."** 즉 스크롤 콘텐츠는 옮기지 않습니다. |
| [4:00](https://developer.apple.com/videos/play/tech-talks/111463/?time=240) | 어디로 옮길지는 자세에 따라 다릅니다. 책처럼 접었을 때 **alert는 trailing 쪽**으로 갑니다(기기를 닫으면 이어지는 외부 화면 쪽). 테이블에 세워 두었을 때는 **위쪽 영역에 멀리서 볼 콘텐츠**를, **아래쪽 영역에 미디어 컨트롤 같은 인터랙티브 요소**를 둡니다. 둘 다 가능하면 맥락을 유지하는 쪽을 택합니다. |
| [5:12](https://developer.apple.com/videos/play/tech-talks/111463/?time=312) | **action sheet, alert, menu, popover는 시스템이 자동으로 reserved region 주변으로 재배치합니다.** split view는 50:50으로 맞춰지고, 그리드는 바깥 여백을 유지하면서 힌지 주변 간격을 넓힙니다. |
| [6:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=399) | `GeometryReader`나 `onGeometryChange`에서 얻은 proxy의 `reservedRegions(kind:)`로 조회합니다. UIKit은 `view.reservedRegions(kind:)`입니다. |
| [7:50](https://developer.apple.com/videos/play/tech-talks/111463/?time=470) | 기본적으로 활성 영역만 반환하며, `.includeInactive`를 주면 비활성 영역도 받습니다. 폈을 때 힌지 영역은 비활성이고 폭이 0입니다. 팁: division이 존재하면(활성 여부와 무관하게) 그리드 열을 짝수로 두는 식의 판단에 쓸 수 있습니다. occlusion(FaceTime 카메라)은 카메라 사용 중에만 활성화됩니다. |
| [8:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=519) | NavigationStack, NavigationSplitView, TabView, List, ScrollView 같은 시스템 컨테이너는 힌지에 "공짜로" 적응합니다. |
| [9:20](https://developer.apple.com/videos/play/tech-talks/111463/?time=560) | Arrangement란 입력(가로·세로 size class, 화면 비율, 활성 division)을 받아 출력(각 뷰의 표시 여부와 frame)을 내는 함수입니다. |
| [12:00](https://developer.apple.com/videos/play/tech-talks/111463/?time=720) | `.split`(기본값)은 가로가 길면 좌우로, 세로가 길면 위아래로 나눕니다. `.split.axes(.horizontal)`처럼 축을 제한했는데 그 축으로 나눌 수 없으면 **primary만 표시**합니다. |
| [13:21](https://developer.apple.com/videos/play/tech-talks/111463/?time=801) | `.overlay`는 두 뷰를 겹쳐서 배치하다가 **접히면 나란히 배치**합니다. `overlayArrangementZIndex`로 접힘/펼침 상태에 따라 UI를 축소판·확장판으로 바꿀 수 있습니다. |
| [14:39](https://developer.apple.com/videos/play/tech-talks/111463/?time=879) | 고르는 기준: HStack/VStack 구조면 split, ZStack 구조면 overlay입니다. 전경·배경 관계면 overlay, main-detail 관계처럼 둘 다 가려지면 안 되면 split입니다. |
| [16:09](https://developer.apple.com/videos/play/tech-talks/111463/?time=969) | ArrangementView 안에 NavigationSplitView를 넣지 말고, List나 ScrollView 안에 ArrangementView를 넣지 마세요. |

## 영상에 나오지 않은 SDK 세부 사항
- `ReservedRegion`에는 `frame` 외에 **`margins`**(인터랙티브 콘텐츠를 위한 여유 여백)와 `isActive`가 있습니다. 헤더 설명상 `frame`에는 이 margins가 포함됩니다.
- `reservedRegions(kind:options:layoutDirectionBehavior: = .mirrors)`는 RTL 언어에서 영역을 자동으로 좌우 반전합니다. 반전 없이 하드웨어 좌표가 필요하면 `.fixed`를 넘깁니다.
- `splitArrangementLayoutRatio`/`splitArrangementLayoutSize`로 분할 비율과 크기를, `overlayArrangementEdge`로 overlay 가장자리를 조정할 수 있습니다.
