# 06. iPhone Duo 대응 시 추가로 고민하면 좋은 포인트 (범용)

> **EN summary:** A general checklist that goes beyond layout: state continuity across displays, multiple scenes and shared state, playback and PiP, resizing performance, content aspect ratios, input and reachability, accessibility, and QA. Each point links to evidence.

## 1. 화면 전환 시 상태 연속성
- 기기를 열고 닫으면 앱이 외부 화면과 내부 화면 사이를 **이동하고 리사이즈**됩니다. HIG는 "Keep functionality and the state of elements the same between displays"라고 합니다(D1).
  - 입력 중인 텍스트, 스크롤 위치, 선택 상태, 진행 중인 작업이 **리사이즈 후에도 유지**되는지 확인합니다.
  - size class가 바뀔 때 뷰 트리가 통째로 교체되면(`if compact { A } else { B }`) 상태가 사라집니다. 상태는 뷰 바깥의 모델에 두고, 구조가 바뀌어도 `id`가 유지되게 합니다.
- 정지 화면 캡처만으로는 상태 손실, 끊긴 애니메이션, 순간적으로 튀는 뷰를 찾을 수 없습니다(T2). **접기와 펴기를 반복하는 동적 테스트**가 필요합니다.

## 2. 멀티 scene과 공유 상태
- iPhone Duo는 여러 인스턴스(창)를 지원하며, **새 창은 내부 화면에서만** 열 수 있습니다(S4 3:38).
- 같은 앱의 인스턴스끼리는 `AppStorage`나 공용 저장소 같은 **기반 상태를 공유**합니다(T1). 싱글턴 매니저가 "화면이 하나"라고 가정하고 있지 않은지 점검합니다.
- 창을 여는 버튼은 `UIWindowSceneActivationAction` 등을 써서, 창을 열 수 없는 상황에서는 자동으로 숨겨지게 합니다(S4).

## 3. 재생과 PiP가 있는 앱이라면
- PiP를 **상단에 고정**할 수 있고, 반쯤 접으면 비디오가 화면 절반을 차지합니다(S6). 다른 앱의 PiP 때문에 **우리 앱의 높이가 줄어드는 상황**도 기본 시나리오로 다룹니다([05](research/05-pip-resize.md)).
- 테이블에 놓은 자세에서는 "미디어는 위, 컨트롤은 아래"를 권장합니다(S6, S3). `ArrangementView(.overlay)`로 구현하는 방안은 [02](research/02-player-arrangement.md)를 참고하세요.
- 전체 화면 재생 화면은 세로 바를 끄는 것(`toolbarVerticalBehavior(.disabled)`)을 검토합니다(H4, D9).
- 자막이나 오버레이 텍스트는 safe area와 division region을 피해야 합니다([07](research/07-safe-area-dynamic-island.md)).

## 4. 콘텐츠 비율
- 내부 화면은 **약 1.42:1**(669×951pt)로 정사각형에 가깝습니다(M1, T3).
  - 16:9 콘텐츠를 폭에 맞추면 위아래에 여백이 크게 남습니다.
  - 반대로 문서, 2단 레이아웃, 그리드에는 유리합니다.
- 썸네일과 카드 비율은 고정 크기가 아니라 **컨테이너 비율 기준**으로 정합니다.
- 배경 아트워크는 비율을 바꾸지 말고 **채우도록 스케일**합니다. 핵심 피사체는 safe area 안에 둡니다(D10).

## 5. 리사이즈 성능
- 크기는 실시간으로 계속 바뀝니다. 접는 동안, PiP 크기가 바뀔 때, Split View를 조정할 때가 해당합니다(S6).
  - 크기가 바뀔 때 무거운 작업(이미지 재디코딩, 네트워크 재요청, 레이아웃 전체 재계산)을 하지 않게 합니다.
  - `displayScale`이 바뀌면 캐시를 무효화합니다. `UIScreen.main.scale` 대신 trait를 씁니다(S1 9:25, S7).

## 6. 입력과 조작성
- 외부 화면 컨트롤은 **오른손 엄지 기준 오른쪽 세로 바**에 있습니다(S6). 앱 고유의 플로팅 버튼(FAB)이 이 바와 겹치거나 경쟁하지 않는지 확인합니다.
- 반쯤 접은 상태에서 힌지 위에 있는 버튼은 누르기 어렵습니다(S6 9:28).
- 하드웨어 키보드, 트랙패드, 포인터를 쓰는 상황도 고려합니다. iPad처럼 쓰일 수 있습니다.

## 7. 접근성
- Dynamic Type을 최대 크기로 키웠을 때 외부 화면(낮은 높이)과 PiP 고정 상태에서 레이아웃이 버티는지 확인합니다.
- Reduce Transparency를 켜면 세로 바 뒤쪽의 외형이 바뀝니다(T1).
- VoiceOver 탐색 순서가 세로 바 이동 후에도 자연스러운지 확인합니다.

## 8. 호환성과 배포
- 최신 SDK와 **UIScene lifecycle은 필수**입니다. scene lifecycle이 없으면 앱이 실행되지 않습니다(S7 2:10).
- iOS 27 SDK로 링크하면 **리사이즈를 끌 수 없습니다**(T1). 그러므로 대응 범위는 "iPhone Duo 전용 기능"이 아니라 **모든 크기 변화**입니다.
- 이전 SDK로 빌드한 앱은 레터박스 호환 모드로 표시됩니다(T1). 업데이트가 늦어질수록 사용자가 보는 화면 품질에 차이가 벌어집니다.

## 9. QA 매트릭스 (최소)

| 축 | 값 |
|----|----|
| 화면 | 외부, 내부 |
| 방향 | 세로, 가로 |
| 자세 | 닫힘, 펼침, 책, 랩톱(테이블) |
| 멀티태스킹 | 전체 화면, Split View 왼쪽/오른쪽, PiP 상단 고정 |
| 접근성 | 기본, AX5 텍스트, Reduce Transparency |
| 언어 | LTR, RTL |

자동화 방법은 [08](research/08-screenshot-automation.md)을 참고하세요.

## 출처
S1, S3, S4, S6, S7, D1, D9, D10, H4, M1, T1, T2, T3. [sources.md](sources.md)
