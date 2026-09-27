# 04. `.onHingeChange`: 실무에서 어떻게 쓸 수 있을까?

> **EN summary:** Treat the hinge as an **input device and a context signal, not a layout signal**. Apple: "Hinge data is observed live, and is ideal for driving interactions or effects. For layout, use the arrangement and region APIs." (S4 2:35). Good uses: continuous controls such as scrubbing, zoom, or a pitch bend; motion effects such as parallax and a "book cover" feel; posture-aware *hints*; and analytics on how people hold the device. Bad uses: switching layouts on `status`. Use size classes, `ArrangementView`, and reserved regions for that. `UIHinge.angle` is in radians and the update rate is system policy.

상태: **조사 완료. 데모는 아직입니다.**

## API 정리 (iOS 27.1 SDK 기준)

```swift
// SwiftUI
.onHingeChange(isEnabled: Bool = true) { old, new in
    guard let hinge = new.hinge else { return }  // nil: 힌지가 없는 기기이거나, 업데이트를 받지 않는 계층
    hinge.status  // .closed / .partiallyOpen / .fullyOpen
    hinge.angle   // Angle (SwiftUI). UIKit UIHinge.angle은 radians(CGFloat)
}
// UIKit
view.addInteraction(UIHingeInteraction { _, update in update.hinge })
```

- 핸들러는 **처음 한 번 현재 상태로 호출되고**, 이후 변경될 때마다 호출됩니다. 뷰가 다른 계층으로 이동할 때도 호출됩니다(H1).
- `isEnabled=false`인 동안에는 업데이트가 **쌓이지 않습니다**. 다시 켜면 현재 상태를 한 번 전달합니다(H1).
- 각도 업데이트의 빈도와 정밀도는 시스템 정책이라 **보장되지 않습니다**. 열림·닫힘 여부만 필요하면 각도 대신 `status`를 쓰는 것이 권장됩니다(H1).
- `status`는 각도와 **기기 방향**을 함께 보고 시스템이 판단합니다(D7).

## 활용 아이디어 (범용)

| 분류 | 아이디어 | 적합도 | 메모 |
|------|----------|--------|------|
| 연속 입력 | 반쯤 접은 상태에서 각도로 **타임라인 스크럽, 줌, 슬라이더 조작** | ◎ | Apple 기타 예제(피치 벤드)와 같은 패턴입니다. 반드시 `.partiallyOpen`일 때만 적용하고, 그 외에는 초기화합니다(S4 1:18). |
| 모션 효과 | 각도에 따른 **패럴랙스, 3D 틸트, 책 표지를 넘기는 듯한 애니메이션** | ◎ | 효과만 바꾸고 레이아웃은 건드리지 않습니다. |
| 자세 힌트 | 랩톱 자세로 바뀌면 "테이블 모드" 안내 토스트, 컨트롤을 크게 표시 | ○ | 기능을 바꾸지 말고 보조 힌트만 줍니다. 레이아웃 전환은 ArrangementView가 맡습니다. |
| 핸즈프리 | 테이블에 세워 두면 **자동 재생이나 슬라이드쇼 모드를 제안** | ○ | 자동으로 전환하기보다는 제안하는 것이 안전합니다. |
| 입력 보조 | 각도가 빠르게 바뀌는 동안(접는 중)에는 **제스처 인식을 잠시 무시**해 오조작 방지 | △ | 업데이트 빈도가 보장되지 않으므로 보수적으로 씁니다. |
| 분석 | 자세 분포를 수집(닫힘, 펼침, 반쯤 접힘 비율) → 어떤 레이아웃에 투자할지 판단 | ◎ | 원시 각도는 저장하지 말고 `status` 단위로 집계합니다. |
| 절전·성능 | 닫히는 중이면 무거운 애니메이션이나 프리페치를 중지 | △ | 닫힌 뒤의 처리는 scene 생명주기와 크기 변화로 처리하는 것이 정석입니다. |

## 하지 말아야 할 것
- `status == .partiallyOpen`이라는 이유로 **VStack을 HStack으로 바꾸는 식의 레이아웃 전환** → `ArrangementView`나 `reservedRegions`를 씁니다(S4 2:35).
- 각도로 **힌지의 위치(frame)를 계산** → division region의 frame을 씁니다.
- 힌지가 없는 기기(nil)에서 기능이 **사라지게** 만드는 것 → 힌지 기반 인터랙션은 항상 **선택적인 보너스**여야 합니다. HIG의 "Maintain the same functionality"와도 연결됩니다.

## 데모 설계 (04_Hinge)
1. 각도와 상태를 실시간으로 보여주는 게이지. 각도는 SwiftUI `Angle`로, UIKit과 비교하기 위해 radians로도 표시합니다.
2. 각도에 연동한 패럴랙스 카드 스택.
3. `.partiallyOpen` 동안 각도로 타임라인을 스크럽하는 프로토타입.
4. status 전환 로그: old → new, 타임스탬프 기록. 업데이트 빈도를 관찰하기 위한 것입니다.
- 시뮬레이터에서는 ⌥ 키를 누른 채 Device Hub의 힌지 슬라이더로 각도를 조절합니다(T2). `devicectl device motion hinge-angle`로 교차 검증합니다(M3).
- 결과: _TBD_

## 출처
S4(1:18, 2:35), D6, D7, D8, H1, M3, T2
