# Leverage multiple displays and scenes on iPhone Duo (Tech Talk 111464)

- URL: https://developer.apple.com/videos/play/tech-talks/111464/
- 길이: 약 7분
- 발표: Chris Donegan, Alex Muller
- 확인일: 2026-09-28

## 세 줄 요약
- `onHingeChange`와 `UIHingeInteraction`은 힌지 **상태**(closed / partiallyOpen / fullyOpen)와 연속적인 **각도**를 알려줍니다. **효과와 인터랙션용이며, 레이아웃 결정에는 쓰지 않습니다.**
- **모든 앱이 Split View 멀티태스킹에 참여합니다.** iPhone Duo에는 **비디오와 앱을 위아래로 쌓는 새 레이아웃**(PiP를 상단에 고정)도 있으며, 앱은 두 경우를 똑같이 처리하면 됩니다.
- iPhone Duo는 멀티 scene을 지원하는 첫 iPhone입니다. 다만 **새 창은 내부 화면에서만** 만들 수 있습니다. 카메라 앱은 `CameraCaptureAccessory`로 외부 화면에도 UI를 띄울 수 있습니다.

## 핵심 내용

| 시점 | 내용 |
|------|------|
| [0:49](https://developer.apple.com/videos/play/tech-talks/111464/?time=49) | SwiftUI는 `onHingeChange`, UIKit은 `UIHingeInteraction`을 씁니다. |
| [1:18](https://developer.apple.com/videos/play/tech-talks/111464/?time=78) | 예시로 기타 앱이 `.partiallyOpen` 상태일 때만 힌지 각도를 피치 벤드에 연결합니다. hinge가 nil이면 힌지가 없는 기기입니다. |
| [2:35](https://developer.apple.com/videos/play/tech-talks/111464/?time=155) | **"Hinge data is observed live, and is ideal for driving interactions or effects. For layout, use the arrangement and region APIs."** 즉 레이아웃은 arrangement와 region API로 처리하라는 뜻입니다. |
| [2:59](https://developer.apple.com/videos/play/tech-talks/111464/?time=179) | 모든 앱이 멀티태스킹에 참여합니다. **"iPhone Duo has a completely new layout, stacking video and apps together. Your app handles both of these layouts the same."** 두 레이아웃 모두 size class와 scene geometry로 대응합니다. |
| [3:38](https://developer.apple.com/videos/play/tech-talks/111464/?time=218) | 새 창은 내부 화면에서만 생성할 수 있습니다. scene 요청이 실패하는 경우를 처리해야 하며, `UIWindowSceneActivationAction`은 새 창을 열 수 없을 때 자동으로 숨겨집니다. |
| [5:00](https://developer.apple.com/videos/play/tech-talks/111464/?time=300) | `CameraCaptureAccessory`는 내부 화면에서 카메라를 쓰는 동안 외부 화면에 UI를 표시합니다. 조건은 내부 화면 전체 화면 + 카메라 세션 활성입니다. |

## SDK 시그니처 메모
- SwiftUI `DeviceHinge.angle`의 타입은 `Angle`이고, UIKit `UIHinge.angle`은 **라디안 단위 `CGFloat`**입니다.
- UIKit의 status에는 `.unknown`도 있습니다.
- 헤더 주석: 각도 업데이트 빈도와 정밀도는 시스템 정책이므로 특정 값에 의존하면 안 됩니다. 열림·닫힘 여부만 필요하면 각도 대신 `status`를 쓰라고 합니다.
- `isEnabled = false`인 동안에는 업데이트가 쌓이지 않습니다. 다시 켜면 현재 상태를 한 번 전달합니다.
