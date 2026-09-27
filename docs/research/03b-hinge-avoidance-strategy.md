# 03-b. 직접 배치한 인터랙티브 요소의 힌지 회피 전략 (초안)

> **EN summary:** System components (sheets, alerts, menus, toolbars, split views) avoid the fold on their own. Anything we lay out ourselves does not (M13: a plain `Button` stayed on the hinge). The strategy has three parts. (1) **Classify** each element by how it is laid out: scrolling content, fixed composite, floating element, or background. Each class gets exactly one rule. (2) Provide **one shared infrastructure**: a root-level provider publishes the active division frames (read reactively) through the environment, plus three reusable tools: `ArrangementView`, a `HingeSplitLayout`, and a `.hingeDisplaced()` modifier. (3) **Verify** with the debug overlay and the pose capture script. Never hard-code the hinge width. Use `isActive` plus the region frame.

## 전제 (측정과 Apple 가이드)
- 시스템 컴포넌트만 힌지를 피합니다. 직접 배치한 `Button`은 힌지 위에 그대로 남습니다(M13, S6 9:28).
- **스크롤 콘텐츠는 옮기지 않습니다.** 사용자가 스크롤로 힌지에서 벗어나게 할 수 있기 때문입니다(S3 2:26, S6 9:28).
- 옮기더라도 **필요한 만큼만, 작게** 옮깁니다. 원래 위치와의 관계를 유지합니다(S3 2:26, D1 "Avoid extreme layout changes").
- 옮길 방향은 **맥락 우선**입니다. 테이블 자세는 아래쪽, 책 자세는 trailing 쪽입니다(S3 4:00).
- 판단 기준은 `isActive`와 region의 `frame`만 씁니다. **폭 값(40pt)은 쓰지 않습니다.** 펼쳐도 40pt로 보고되며, 보장된 값이 아닙니다(M12).
- region 정보는 첫 레이아웃 직후에는 비어 있고 조금 뒤에 들어옵니다. 따라서 **반응형으로 읽어야 합니다**(M9).

## 1. 분류: 요소마다 규칙은 하나

| 분류 | 예시 | 규칙 | 도구 |
|------|------|------|------|
| **A. 스크롤 콘텐츠** | 리스트, 그리드, 피드, 본문 | **옮기지 않음.** 그리드만 예외로, division이 있으면 **짝수 열 + 힌지 위치에 거터**를 둡니다(책 자세). | `LazyVGrid` 열 수 보정 |
| **B. 고정 복합 화면** (스크롤 없는 화면 전체) | 플레이어, 카메라, 에디터 캔버스와 툴 패널, 대시보드 | **화면을 두 영역으로 나눕니다.** 관계가 "전경/배경"이면 overlay, "main/detail"이면 split을 씁니다. | `ArrangementView` (1순위), `HingeSplitLayout` (2순위) |
| **C. 떠 있는 요소** | FAB, 토스트, 커스텀 팝업, 코치마크, 하단 고정 CTA, 미니 플레이어 | 힌지와 겹칠 때만 **가장 가까운 영역으로 최소 이동**합니다. 방향은 선호 규칙(맥락 → bottom/trailing)을 따릅니다. | `.hingeDisplaced()` |
| **D. 배경과 장식** | 배경 이미지, 그라디언트, 비디오 표면 | **아무것도 하지 않습니다.** 끝까지 채웁니다. | — |

판단이 애매하면 "이 요소는 스크롤되는가?"를 먼저 묻습니다. 스크롤되면 A, 아니면 B/C입니다.

## 2. 공용 인프라

### 2-1. Root 단의 힌지 정보 제공자
- 앱 루트에서 **한 번만** 활성 division을 반응형으로 읽고, **window(global) 좌표**로 environment에 넣습니다.
- 각 컴포넌트는 자기 frame(global)과 비교만 하면 됩니다. 곳곳에 `GeometryReader`를 두지 않아도 됩니다.
- 첫 값이 비어 있는 문제는 이 계층에서 한 번에 처리합니다.

```swift
struct ActiveDivisions: Equatable { var frames: [CGRect] = [] }   // global 좌표, isActive만 포함

extension EnvironmentValues {
    @Entry var activeDivisions = ActiveDivisions()
}

struct HingeProvider: ViewModifier {
    @State private var divisions = ActiveDivisions()
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: ActiveDivisions.self) { proxy in
                let origin = proxy.frame(in: .global).origin
                return ActiveDivisions(frames: proxy.reservedRegions(kind: .division)   // 기본값은 활성만 반환 (M13)
                    .filter(\.isActive)
                    .map { $0.frame.offsetBy(dx: origin.x, dy: origin.y) })
            } action: { divisions = $0 }
            .environment(\.activeDivisions, divisions)
    }
}
```

### 2-2. 도구 3종

| 도구 | 쓰임 | 동작 |
|------|------|------|
| `ArrangementView` | B 분류, 두 덩어리 화면 | 시스템에 맡깁니다. 측정 결과, overlay는 평소 겹침이고 접으면 힌지 기준으로 분리됩니다(M11–M13). |
| `HingeSplitLayout` (커스텀 `Layout`) | B 분류, 3개 이상이거나 비율을 세밀하게 정해야 하는 경우 | 자식들을 힌지 앞/뒤 영역에 나눠 배치합니다. 자식마다 `.hingeRegion(.leadingOrTop / .trailingOrBottom)`로 배정합니다. 힌지가 비활성이면 일반 스택처럼 동작합니다. |
| `.hingeDisplaced(prefer:)` | C 분류 | 자기 frame이 활성 division과 **겹칠 때만**, 선호 방향(`.contextual`, `.bottom`, `.trailing`)으로 **최소 거리**만큼 offset을 줍니다. 애니메이션을 적용합니다. 이동할 영역이 요소보다 작으면 반대쪽으로 갑니다. |

```swift
// 사용 예
FloatingActionButton().hingeDisplaced(prefer: .bottom)
ToastView().hingeDisplaced(prefer: .contextual)
PromoPopup().modifier(HingeAwareOverlay(...))   // 실험 03에서 구현한 것
```

UIKit은 같은 개념으로 대응합니다. `view.reservedRegions(kind: .division)`을 `layoutSubviews`에서 읽고, 힌지를 제외한 `UILayoutGuide` 2개(앞/뒤 영역)를 만들어 제공하면 됩니다.

### 2-3. 쓰지 않을 것
- `onHingeChange`의 각도나 상태로 레이아웃을 분기하는 것(S4 2:35)
- 힌지 폭 상수(40pt)나 화면 중앙 좌표를 하드코딩하는 것
- `onAppear`에서 한 번만 region을 읽는 것(M9)

## 3. 적용 절차 (기존 화면 대응 순서)
1. **목록화:** 화면별로 스크롤 없이 직접 배치한 인터랙티브 요소를 추립니다. 대상은 B와 C 분류뿐입니다.
2. **우선순위:** 자주 쓰는 컨트롤 → 결제·확인 같은 중요 CTA → 나머지 순서로 처리합니다. 전부 할 필요는 없습니다(S3 16:34 "highest priority manually laid-out controls").
3. **도구 적용:** B 분류는 `ArrangementView`로 먼저 시도하고, 안 되면 `HingeSplitLayout`을 씁니다. C 분류는 `.hingeDisplaced`를 씁니다.
4. **검증:** 디버그 오버레이를 켜고 책 자세와 랩톱 자세에서 캡처합니다(`tools/duo-capture`). **활성 division과 겹치는 인터랙티브 요소가 0개**여야 합니다.
5. **자동 점검(선택):** DEBUG 빌드에서 `.hingeDisplaced`와 `HingeSplitLayout`이 겹침을 감지하면 로그를 남깁니다. 캡처와 로그를 함께 보면 회귀를 확인할 수 있습니다.

## 4. 결정해야 할 것
- C 분류 기본 방향의 우선순위: `contextual → bottom → trailing`으로 할지 여부
- 하단 고정 CTA 바(C): 랩톱 자세에서는 원래 아래 영역에 있어 문제없습니다. 책 자세에서는 좌우 중 어느 쪽에 둘지, 혹은 양쪽 영역 폭으로 **둘로 나눌지** 정해야 합니다.
- 미니 플레이어나 플로팅 패널처럼 사용자가 드래그로 옮길 수 있는 요소: 힌지 위에 놓으면 **가까운 쪽으로 스냅**시킬지

## 다음 단계
- `HingeProvider`, `.hingeDisplaced`, `HingeSplitLayout`을 DuoLab `Shared/`에 구현합니다.
- 실험 03에 FAB, 토스트, 하단 CTA 샘플을 추가하고, 책 자세와 랩톱 자세에서 before/after 캡처를 비교합니다.
