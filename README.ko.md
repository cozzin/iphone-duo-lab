# DuoLab: iPhone Duo 적응형 레이아웃 실험

iPhone Duo(폴더블 iPhone, iOS 27.1)에 대한 Apple의 가이드를 직접 검증하는 Tuist 기반 SwiftUI 샘플 앱과 조사 문서입니다.

## 질문과 결론 요약

| # | 질문 | 요약 (현재 근거 기준) | 문서 |
|---|------|----------------------|------|
| 1 | 왜 size class이고, 왜 compact/regular 두 개만 타겟팅하나? | 자세, 화면, 멀티태스킹 조합이 폭발적으로 많아서 디바이스를 판별하는 방식은 유지할 수 없습니다. **구조는 size class 2벌, 내부 요소는 가변**으로 만드는 것이 Apple 모델입니다. | [01](docs/research/01-size-class.md) |
| 1-b | width breakpoint 3단계 레이아웃은? | Apple은 "Avoid fixed widths, **breakpoints**…"라고 명시합니다. 치명적인 위험은 **잘못된 폭을 측정하는 것**과 **시스템의 전환 시점과 어긋나는 것**입니다. 권장안은 하이브리드: size class로 구조, 컨테이너 폭으로 밀도를 정합니다. | [01-b](docs/research/01b-breakpoint-vs-size-class.md) |
| 2 | partially open일 때 render는 위, control은 아래 배치 → ArrangementView? | 가능할 것으로 봅니다. `.overlay`에 primary=컨트롤, secondary=렌더를 두면, partially open일 때 primary가 trailing/하단으로 갑니다(문서 기준). 실험으로 검증할 예정입니다. | [02](docs/research/02-player-arrangement.md) |
| 3 | custom popup은 힌지를 피하지 않는다. 어떻게 피하나? | 시스템 popup만 자동으로 피합니다. 커스텀은 `reservedRegions(.division)`으로 직접 처리합니다. 위치 규칙: 책 자세는 trailing, 테이블 자세는 아래쪽, 가능하면 트리거가 있는 영역. | [03](docs/research/03-custom-popup.md) |
| 4 | `.onHingeChange` 실무 활용 | 효과와 인터랙션, 분석용입니다. **레이아웃 결정에는 쓰지 않습니다.** | [04](docs/research/04-hinge.md) |
| 5 | PiP 고정 + portrait 고정 앱 | 앱이 세로 방향으로 **실제 리사이즈**됩니다. iOS 27 SDK 이상에서는 portrait 고정이 무시되고, 이전 SDK는 레터박스로 표시됩니다. | [05](docs/research/05-pip-resize.md) |
| 6 | 추가 고려사항 | 상태 연속성, 멀티 scene, 리사이즈 성능, 콘텐츠 비율, 접근성, QA 매트릭스 | [considerations](docs/considerations.md) |
| 7 | 배경 full-bleed vs Dynamic Island | 배경은 끝까지 채워도 됩니다. 텍스트와 컨트롤은 safe area 안에 둡니다. iPhone Duo는 **옆쪽(세로 바 쪽) inset**이 핵심입니다. | [07](docs/research/07-safe-area-dynamic-island.md) |
| 8 | 레이아웃 스크린샷 자동화 | 디스플레이별 캡처와 힌지 각도 읽기는 가능합니다. 자세 설정 CLI는 없어서 Device Hub AX 헬퍼나 반자동 방식을 씁니다. | [08](docs/research/08-screenshot-automation.md) |

## Apple 자료 정리
- 한국어: [docs/apple/ko](docs/apple/ko/README.md)
- English: [docs/apple/en](docs/apple/en/README.md)
- 근거 목록: [docs/sources.md](docs/sources.md)

## 실행
Xcode 27.1과 [Tuist](https://tuist.dev)가 필요합니다.

```sh
tuist generate
xcodebuild -scheme DuoLab -destination 'platform=iOS Simulator,name=iPhone Duo' build
```
