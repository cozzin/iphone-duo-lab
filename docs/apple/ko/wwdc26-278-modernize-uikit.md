# Modernize your UIKit app (WWDC26 session 278)

- URL: https://developer.apple.com/videos/play/wwdc2026/278/
- 길이: 약 16분
- 확인일: 2026-09-28

## 세 줄 요약
- iOS 27부터 iPhone 앱은 **리사이즈 가능한 환경**(iPhone Mirroring, iPhone Duo)에서 실행됩니다. 최신 SDK에서는 **UIScene lifecycle이 필수**입니다.
- **지원 방향(supported interface orientations)은 이제 "선호"일 뿐이며, 리사이즈 환경에서는 무시됩니다.** `UIRequiresFullScreen`을 켜도 리사이즈에서 빠지는 게 아니라, 크기가 단계적으로 바뀌는 *discrete* 리사이즈로 동작합니다.
- 레이아웃에 `UIScreen.main`, idiom, 방향을 쓰지 말고 trait, scene geometry, view bounds를 쓰세요.

## 핵심 내용

| 시점 | 내용 |
|------|------|
| [2:10](https://developer.apple.com/videos/play/wwdc2026/278/?time=130) | "UIScene lifecycle is now required when building with the latest SDKs. Without it, your application will no longer launch." 즉 scene 기반이 아니면 앱이 실행되지 않습니다. |
| [2:51](https://developer.apple.com/videos/play/wwdc2026/278/?time=171) | `UIScreen.main` 대신 `windowScene.screen`과 `traitCollection.displayScale`을 씁니다. scene 크기 변화는 `windowScene(_:didUpdateEffectiveGeometry:)`로 감지합니다. |
| [5:46](https://developer.apple.com/videos/play/wwdc2026/278/?time=346) | "UIRequiresFullscreen … **no longer opts your app fully out of resizing. Instead, it enables discrete resizing that honors your supported interface orientations.**" 즉 이 키를 켜도 리사이즈는 일어나고, 대신 지원 방향을 지키는 단계적 리사이즈가 됩니다. |
| [6:17](https://developer.apple.com/videos/play/wwdc2026/278/?time=377) | idiom은 더 이상 레이아웃 판단에 의미가 없습니다. |
| [6:50](https://developer.apple.com/videos/play/wwdc2026/278/?time=410) | "**In iOS 27, an app's supported interface orientation is a preference provided to the system. It will be ignored when your app is running in a resizable environment.**" iPhone Mirroring에서는 화면 비율과 관계없이 항상 portrait 방향으로 실행됩니다. 방향 체크는 size class로 바꾸라고 합니다. |
| [14:07](https://developer.apple.com/videos/play/wwdc2026/278/?time=847) | Xcode의 app modernization agent skill을 소개합니다. `xcrun agent skills export`로 skill을 Markdown으로 내보낼 수 있습니다. |

## Portrait 고정 앱에 주는 의미 (실험 05와 연결)
- **외부 화면**: 지원 방향이 존중됩니다(S1).
- **내부 화면, Split View, PiP 고정 상태**: 리사이즈 환경이므로 **portrait 고정 설정은 무시되고 앱이 리사이즈됩니다**(S1, S7, T1).
- 이전 SDK로 빌드한 앱은 호환 모드(레터박스)로 표시됩니다(T1: "Apps built with Xcode 26 are letterboxed on the inner display").
- iOS 27 SDK로 링크한 앱은 리사이즈를 끌 수 없습니다(T1: "Once the app links against iOS 27, it gets iPhone resizability.").
