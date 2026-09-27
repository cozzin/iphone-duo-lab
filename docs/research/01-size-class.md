# 01. 애플은 왜 size class를 권장하고, 왜 compact/regular width 두 개만 타겟팅하라고 할까?

> **EN summary:** On iPhone Duo an app can appear at many sizes: two displays, six-plus poses, rotation, a 50/50 Split View, and a vertically resized app under a pinned PiP. The *layout* stays small, though. Only two horizontal size classes occur: compact on the outer display and regular on the inner display. Apple's model is **two structural layouts + fluid content**. The structure (tabs vs. sidebar, one vs. two columns) switches on size class. Everything inside flows with the container size (grids, margins, `ViewThatFits`, `ArrangementView`). That is realistic *if* "everything else is fluid" is taken seriously.

상태: **조사 완료. 예시 앱 측정은 아직 진행 전입니다.**

## 왜 size class인가 (근거)
1. **조합이 너무 많습니다.**
   - 앱이 나타날 수 있는 환경: 외부/내부 화면 × 자세(닫힘, 펼침, 책, 랩톱, 텐트, 세로 세움) × 회전 × Split View(50/50) × PiP 상단 고정(세로 리사이즈) × 멀티 윈도우. 그 밖에 iPhone Mirroring(자유 리사이즈)과 iPad도 있습니다(S4 2:59, S6 ~1:40, S7).
   - 이 조합마다 디바이스를 판별해 분기하는 방식은 유지할 수 없습니다.
2. **디바이스 정보로는 "지금 쓸 수 있는 공간"을 알 수 없습니다.**
   - Apple은 layout에 idiom, interface orientation, `UIScreen.main`을 쓰지 말라고 합니다(S1 2:46·3:57, S7 6:17·6:50, D2).
   - 같은 내부 화면이어도 Split View 한쪽, PiP 아래, 전체 화면일 때 앱의 크기가 모두 다릅니다.
3. **size class는 시스템 컴포넌트가 실제로 반응하는 신호입니다.**
   - `NavigationSplitView`가 컬럼을 접고 펴는 것, `TabView`가 사이드바로 바뀌는 것, sheet의 표시 방식은 모두 size class를 따릅니다(S1 5:01, D1).
   - 앱의 구조를 같은 신호에 맞추면 시스템 UI와 앱 UI가 같은 시점에 전환됩니다.
4. **iPhone Duo에서 실제로 나오는 size class 조합은 적습니다.**
   - 외부 화면은 C/R(세로), C/C(가로)입니다.
   - 내부 화면은 **R/R**입니다(S1 2:46, T3).
   - 가로(horizontal) 기준으로 보면 compact와 regular 두 개뿐입니다.

## "두 개만 타겟팅"의 정확한 의미
> "A compact width layout for the outer display and a regular width layout for the inner display give you the fundamentals for every pose. Don't reinvent your app when it resizes; allow the existing layout to expand based on the available space instead." (D1)

> "Avoid fixed widths, breakpoints, or any metrics tied to a specific screen." (S6 3:42)

두 문장을 합치면 뜻은 다음과 같습니다.
- **구조(structure)**는 2벌만 만듭니다. 탭바와 사이드바, 1단과 2단, 내비게이션 방식이 여기에 해당합니다.
- **내용(content)**은 연속적으로 흐르게 합니다. 컬럼 수, 카드 크기, 여백, 폰트 스케일은 **컨테이너 크기에 따라 가변**입니다.

사용자가 이해한 "나머지는 가변으로 하라는 뜻"이 정확합니다.

## 참고 치수 (3x 기준)

| 환경 | 크기 (pt) | 수평 size class | 출처 |
|------|-----------|-----------------|------|
| 외부 화면, 세로 | 466 × 678 | compact | M1, T3 |
| 외부 화면, 가로 | 678 × 466 | compact (C/C) | S1, 계산값 |
| 내부 화면, 세로 | 669 × 951 | regular | M1, T3 |
| 내부 화면, 가로 | 951 × 669 | regular | M1, 계산값 |
| 내부 화면 Split View 한쪽 (가로 기준) | 약 475 × 669 (추정) | _측정 필요_ | — |
| 내부 화면 + PiP 상단 고정 | 669 × (951 − PiP) | _측정 필요_ | S6 |

> 실제 앱 기준 크기는 safe area와 세로 바 inset에 따라 달라집니다. `_측정 필요_` 항목은 예시 앱의 디버그 오버레이로 기록할 예정입니다.

## 현실성 검토: 어디서 깨질 수 있나
- **"regular인데 폭이 좁은" 구간:** 내부 화면 Split View 한쪽이 어떤 size class를 받는지가 핵심입니다. iPad의 1/2 Split View는 기기에 따라 compact를 받습니다. 폭이 약 475pt면 compact일 가능성이 높지만 **측정이 필요**합니다.
- **"compact인데 폭이 넓은" 구간:** 외부 화면 가로(678pt, C/C)가 해당합니다. 폭은 기존 iPhone 가로와 비슷하지만 **높이가 466pt**로 비교적 여유가 있습니다. compact 레이아웃을 가로로 늘렸을 때 어색하지 않은지 확인해야 합니다.
- **높이가 줄어드는 환경:** PiP를 상단에 고정하면 앱의 **높이만 줄어듭니다**. 가로 size class는 regular 그대로일 수 있습니다. 수직 방향 가변성(헤더 높이, 하단 고정 CTA 등)을 따로 점검해야 합니다.
- **힌지:** size class는 힌지를 알려주지 않습니다. 힌지는 division region과 `ArrangementView`가 담당합니다. 그리드를 짝수 열로 두는 것도 여기에 포함됩니다(S3 7:50, D1).

## 예시 실험 설계 (01_SizeClass)
세 가지 범용 화면을 **구조는 size class로, 내용은 가변으로** 구현합니다.
1. **카탈로그 그리드**
   - compact: 리스트 형태
   - regular: `LazyVGrid(.adaptive(minimum: 160))`
   - division region이 있으면 짝수 열로 보정합니다.
2. **상세 화면**
   - compact: 1단 스크롤
   - regular: `ArrangementView(.split)`로 본문과 부가 정보를 좌우로 나눕니다.
3. **앱 셸**
   - compact: `TabView`
   - regular: `.defaultTabBarPlacement(.sidebar)`
- 모든 화면에 디버그 오버레이를 붙여 h/v size class, 컨테이너 크기, safe area, division frame을 표시합니다.
- 결과: _TBD_

## 출처
S1(2:46, 3:57, 5:01), S3(7:50), S4(2:59), S6(3:42), S7(6:17, 6:50), D1, D2, M1, T3
