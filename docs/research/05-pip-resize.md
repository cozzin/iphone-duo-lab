# 05. PiP를 상단에 고정하고 앱이 리사이즈되면? portrait 고정 앱은 어떻게 보이나?

> **EN summary:** Pinning PiP to the top is an official iPhone Duo layout. Your app **resizes vertically** into the remaining space, and when the device is partially folded the video takes half of the screen (S6, S4 2:59: "Your app handles both of these layouts the same"). With the iOS 27 SDK or later, a **portrait-only setting does not prevent this**. The inner display and every resizable environment treat supported orientations as a preference and ignore them (S1 2:46, S7 6:50, T1). `UIRequiresFullScreen` now only switches to *discrete* resizing (S7 5:46). The app is therefore laid out in a short, wide box (roughly 669 pt wide × about half height) whatever its Info.plist says. Apps linked against older SDKs get a letterboxed compatibility presentation instead (T1). A portrait-only app that assumed a tall screen breaks on height: fixed headers, bottom CTAs, and full-height heroes.

상태: **조사 완료. 시뮬레이터 재현은 아직입니다(PiP 고정을 자동화할 수 있는지부터 확인 필요).**

## 공식 동작 (근거)
- "when a video is playing in picture-in-picture, you can now **pin it to the top of the screen** to keep watching it. **Your current app resizes vertically to fit the space that's left.** And if you partially fold the device, the video extends to fill half of the screen." (S6 ~1:40)
- "iPhone Duo has a completely new layout, stacking video and apps together. **Your app handles both of these layouts the same.**" (S4 2:59). 즉 Split View(좌우)와 같은 방식으로, size class와 scene geometry로 대응합니다.

## portrait 고정 앱은 어떻게 되나

| 빌드 SDK / 설정 | 외부 화면 | 내부 화면 (전체, Split View, PiP 고정) | 근거 |
|------------------|-----------|--------------------------------|------|
| iOS 26 이하 SDK | 호환 모드. status bar와 카메라 왼쪽 영역만 사용하고 레터박스 | 호환 모드. "familiar size and aspect ratio"로 **레터박스**, 가운데 정렬 | S1 0:30, T1 |
| iOS 27 이상 SDK + portrait만 지원 | 지원 방향을 **존중** | 지원 방향이 **무시**되고 **리사이즈**. 남은 공간에 맞춰 레이아웃 | S1 2:46·3:57, S7 6:50, T1 |
| iOS 27 이상 SDK + `UIRequiresFullScreen` | — | 리사이즈에서 빠지지 않습니다. **discrete resizing**, 즉 지원 방향을 지키면서 크기가 단계적으로 바뀝니다. | S1 5:01, S7 5:46 |
| 리사이즈를 끌 수 있나? | — | **불가.** "Once the app links against iOS 27, it gets iPhone resizability." | T1 |

→ 질문하신 "PiP를 고정하고 아래 절반에만 표시되는 상황"은 **최신 SDK 앱이라면 레터박스가 아니라 실제 리사이즈**입니다. 앱은 폭 669pt × 높이 약 400–500pt(추정, 측정 필요)의 **가로로 넓고 낮은 박스**에 portrait 레이아웃을 그리게 됩니다.

## 예상 문제 지점 (portrait 고정 앱 기준)
- 화면 높이를 가정한 **고정 높이 히어로, 헤더, 하단 CTA**가 서로 겹치거나 잘립니다.
- `UIScreen.main.bounds`를 기준으로 계산한 레이아웃은 실제 scene보다 큰 값을 씁니다(S1 3:57).
- 세로 방향(`isPortrait`)을 체크해서 분기하는 코드가 잘못 판단합니다. 방향은 portrait인데 비율은 가로로 넓습니다. iPhone Mirroring에서도 "always portrait interface orientation regardless of aspect ratio"라고 합니다(S7 6:50).
- 키보드, sheet, 하단 고정 바가 함께 나오면 콘텐츠 영역이 0에 가까워질 수 있습니다.
- 반쯤 접으면 PiP 비디오가 화면 절반을 차지하므로, 앱 높이가 한 번 더 줄어듭니다(S6).

## 대응 체크리스트
- [ ] iOS 27 SDK + UIScene lifecycle(필수, S7 2:10)
- [ ] 높이도 가변으로: 스크롤 가능한 루트, `ViewThatFits`로 CTA 축약, 히어로 높이를 컨테이너 비율로 설정
- [ ] `windowScene(_:didUpdateEffectiveGeometry:)` 또는 `onGeometryChange`로 크기 변화 감지(S7)
- [ ] 방향 체크를 size class와 컨테이너 크기 체크로 교체

## 실험 설계 (05_PiPResize)
- 타겟 A: DuoLab(모든 방향 지원). 타겟 B: DuoLabPortraitOnly(Info.plist에 portrait만 지정).
- 두 타겟 모두 같은 "고정 높이 가정" 화면을 씁니다(히어로 300pt + 리스트 + 하단 CTA 80pt).
- 시나리오:
  1. 외부 화면
  2. 내부 화면 전체
  3. 내부 화면 Split View
  4. 다른 앱(Safari 등)의 PiP를 상단에 고정 + 우리 앱
  5. 4번 상태에서 반쯤 접기
- 기록할 값: scene 크기, size class, interface orientation, 레터박스 여부.
- 제약: 시뮬레이터에서 PiP 고정을 자동화할 수 있는지 불명확합니다. 안 되면 Device Hub에서 수동으로 재현하고 절차를 문서화합니다([08](08-screenshot-automation.md)).
- 결과: _TBD_

## 출처
S1(0:30, 2:46, 3:57, 5:01), S4(2:59), S6(~1:40), S7(2:10, 5:46, 6:50), T1
