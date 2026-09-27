# 01-b. 예시 검증: width breakpoint 기반 3단계 레이아웃은 size class 대비 어떤가?

> **EN summary:** A common design-system pattern splits layouts into three tiers at fixed width breakpoints (e.g. S < 500 ≤ M < 800 ≤ L). Apple explicitly advises against it for iPhone Duo: *"Avoid fixed widths, breakpoints, or any metrics tied to a specific screen."* (S6 3:42). It is not fatal in itself. The real risks are measuring the **wrong width** and choosing breakpoints that **disagree with the system's size-class switches**, which leaves our layout and the system's components out of sync. Recommended hybrid: size class decides **structure**; container width (never screen width) decides **density** only, through fluid rules rather than hard tiers wherever possible.

상태: **조사와 분석은 끝났습니다. 비교 구현(A/B/C)과 캡처는 아직입니다.**

이 문서는 흔한 디자인 시스템 패턴을 **일반적인 예시**로 놓고 검증합니다.

## 비교 대상
- **(A) size class 2단계**
  - compact / regular로 구조를 나눕니다.
  - 내부 요소는 가변입니다.
- **(B) width breakpoint 3단계**
  - 예시 기준: S < 500pt ≤ M < 800pt ≤ L
  - 단계마다 구조와 밀도를 정의합니다.
- **(C) 하이브리드**
  - size class로 **구조**를 정합니다(탭바↔사이드바, 1단↔2단).
  - **컨테이너 폭**으로 **밀도**만 정합니다(컬럼 수, 여백, 타이포 스케일). 가능하면 단계 대신 연속 규칙을 씁니다(`adaptive(minimum:)`, `ViewThatFits`, `containerRelativeFrame`).

## (B)의 잠재적 치명 단점

| # | 문제 | 왜 치명적인가 | 근거 |
|---|------|---------------|------|
| 1 | **어떤 폭을 재는가** (화면, scene, 컨테이너) | 화면 폭으로 판단하면 Split View, PiP 고정, 사이드바가 열린 detail 영역, sheet 안에서 **실제보다 큰 단계**를 고르게 됩니다. `UIScreen.main`은 iPhone Duo에서 어느 화면인지부터 모호합니다. | S1 3:57, S7 2:51, D2 ("scene or containing view's bounds") |
| 2 | **시스템 전환 시점과 어긋남** | `NavigationSplitView`, `TabView`, sheet는 **size class로 전환**됩니다. 예를 들어 우리는 L단계(사이드바 디자인)인데 시스템은 compact(탭바)인 구간이 생깁니다. 반대로 우리는 S단계인데 시스템은 이미 2컬럼일 수도 있습니다. **같은 화면에 두 개의 기준이 공존**하게 됩니다. | S1 5:01, D1 |
| 3 | **기기마다 기준값 재조정** | 466, 669, 678, 951pt, Split View 절반, PiP 아래 남는 공간, iPhone Mirroring의 임의 크기까지 새 크기가 계속 늘어납니다. breakpoint는 "지금 아는 기기"에 맞춰진 숫자라서 계속 다시 맞춰야 합니다. | S6 3:42, S7 |
| 4 | **경계에서 흔들림** | 리사이즈(PiP 드래그, 접기, Split View 조정) 중에 폭이 경계값 주변을 오가면 단계가 튀면서 **뷰가 재생성**되고, 스크롤 위치와 입력 상태를 잃을 수 있습니다. | S6 ("apps adjust … in real time"), T2 |
| 5 | **세로 방향 변화를 반영하지 못함** | PiP를 상단에 고정하면 **높이만** 줄어듭니다. 폭 breakpoint로는 이 변화를 전혀 알 수 없습니다. | S6 ~1:40 |
| 6 | **힌지와 Dynamic Type을 반영하지 못함** | 같은 폭이어도 반쯤 접히면 쓸 수 있는 영역이 두 개로 나뉩니다(division). 큰 글꼴이면 같은 폭에서 필요한 레이아웃이 달라집니다. | S3, D1 |
| 7 | **QA와 디자인 매트릭스 폭증** | 3단계 × (외부/내부/Split/PiP/접힘) × 방향 조합이 되어, 단계가 늘어날수록 검증 비용이 곱절로 늘어납니다. | — |

## (B)가 유리한 점 (공정하게)
- 웹이나 Android와 **한 가지 디자인 언어**를 공유하기 쉽습니다.
- 디자이너와 개발자가 소통할 때 "M 사이즈"처럼 **이름 붙은 단계**가 편합니다.
- 밀도(컬럼 수, 여백) 결정에는 폭 기반 규칙이 실제로 유용합니다. 문제는 그 규칙으로 **구조까지** 정하는 것입니다.

## 권장안: (C) 하이브리드
1. **구조 전환은 size class로만 합니다.**
   - 탭바↔사이드바, 1단↔2단(`ArrangementView`/`NavigationSplitView`)이 해당합니다.
   - 이렇게 해야 시스템 컴포넌트와 같은 시점에 전환됩니다.
2. **밀도는 컨테이너 폭으로 정합니다.**
   - `onGeometryChange`나 `containerRelativeFrame`으로 **자기 컨테이너의 폭**을 잽니다.
   - 화면이나 scene 폭은 쓰지 않습니다.
3. **가능하면 단계 대신 연속 규칙**을 씁니다.
   - `GridItem(.adaptive(minimum:))`, `ViewThatFits`, 비율 기반 여백 등입니다.
   - 단계가 꼭 필요하면 **이름은 유지하되 값은 컨테이너 기준으로** 정의합니다.
   - 경계값 주변에는 히스테리시스(예: ±16pt)를 두어 흔들림을 막습니다.
4. **힌지는 별도 규칙으로 다룹니다.**
   - division region이 있으면 짝수 열로 맞춥니다.
   - 인터랙티브 요소는 힌지 밖에 둡니다.

## 디자인 가이드 템플릿 (예시)

```
Layout Guide
1. Structure (size class)
   - compact: Tab bar, single column, sheets from bottom
   - regular: Sidebar (TabView .sidebarAdaptable), two columns (split arrangement)
2. Density (container width; NOT screen width)
   - Grid: adaptive(minimum: 160pt), even columns when a division region exists
   - Margins: layout margins + safe area (asymmetric; never mirror left→right)
   - Typography: Dynamic Type; no width-based font scaling
3. Posture rules
   - Partially open: interactive elements off the hinge; alerts/sheets handled by system
   - PiP pinned: height shrinks; no fixed-height hero/CTA
4. QA matrix: outer P/L, inner P/L, split L/R, PiP pinned, half-fold, AX5 text
```

## 실험 설계
- 같은 카탈로그 화면을 (A)/(B)/(C)로 구현하고 탭으로 전환합니다.
- 오버레이에 "우리 단계"와 "시스템 size class"를 동시에 표시합니다.
- 캡처할 조합: 외부 세로/가로, 내부 세로/가로, Split View, PiP 고정, 반쯤 접힘.
- 목표: **(B)의 단계와 시스템 size class가 불일치하는 캡처**를 수집해 표로 정리합니다.
- 결과: _TBD_

## 출처
S1(3:57, 5:01), S3, S6(3:42, ~1:40), S7(2:51), D1, D2, T2
