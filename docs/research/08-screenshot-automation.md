# 08. iPhone Duo 레이아웃 스크린샷을 자동으로 남기는 도구 검토

> **EN summary:** Capture works per display (`simctl io screenshot --display=<UUID>`). Hinge *readback* works (`devicectl device motion hinge-angle`). There is **no public CLI to set a pose**; it is only exposed through Device Hub's UI (buttons, plus a hinge slider when holding ⌥). The recommended design has three layers. L1: snapshot tests at the target widths and size classes (fast, CI-friendly, no real fold). L2: a simulator capture script driven by deep links, with the pose set by a Device Hub accessibility helper or semi-manually, waiting until the hinge angle is stable. L3: XCUITest for rotation and in-app state.

상태: **L2 반자동 스크립트를 구현했습니다(`tools/duo-capture/capture.sh`). 닫힌 자세에서 동작을 확인했습니다.**

## 사용법

```sh
# 1) Device Hub에서 자세를 설정합니다(버튼, 또는 ⌥ 힌지 슬라이더).
# 2) 현재 자세로 모든 실험을 캡처합니다. 힌지 각도로 closed / open / half<각도>를 자동으로 판별합니다.
tools/duo-capture/capture.sh
tools/duo-capture/capture.sh 02:overlay 02:split          # 일부 실험만
tools/duo-capture/capture.sh -a dev.duolab.portraitonly 05 # portrait 고정 타겟
tools/duo-capture/capture.sh -l split-left 01              # Split View처럼 수동으로 만든 상황에 라벨 추가
```

실행 중 겪은 문제와 해결:
- **`simctl openurl`의 확인 팝업.** 두 앱이 같은 URL scheme을 쓰면 "…에서 열겠습니까?" 알림이 뜨고, 이 알림은 큐에 남습니다. → 딥링크를 **launch argument(`-openURL`)**로 전달하도록 바꾸고, 앱마다 scheme을 분리했습니다.
- **디스플레이 UUID가 바뀜.** 시뮬레이터를 재부팅하면 UUID가 바뀝니다. → 매 실행마다 `simctl io enumerate`로 다시 조회합니다. 폭이 작은 쪽을 외부 화면으로 판단합니다.
- **꺼진 화면 캡처.** 닫힌 상태의 내부 화면처럼 꺼진 화면은 검은 이미지가 됩니다. → 축소한 뒤 20KB 미만이면 삭제합니다.
- **재부팅 직후 첫 실행이 느림.** 실행 후 4초를 기다립니다.

## 확인된 사실 (직접 측정)

| 항목 | 결과 | ID |
|------|------|----|
| 디스플레이 목록 | `xcrun simctl io <udid> enumerate` 결과, Display class 0이 두 개입니다. 외부 **1398×2034**, 내부 **2007×2853** px | M1 |
| 디스플레이별 캡처 | `simctl io <udid> screenshot --display=<port UUID> out.png`는 각 화면을 따로 캡처합니다. 닫힌 상태에서 내부 화면은 검은색으로 찍힙니다. `--display` 없이 찍으면 외부(screenID 1, "LCD")가 기본입니다. | M2 |
| 하드웨어 마스크 | `--mask=black`을 주면 펀치홀 카메라와 둥근 모서리가 표시됩니다. 근거용 캡처에 유용합니다. | M2 |
| 힌지 각도 읽기 | `xcrun devicectl device motion hinge-angle -d <udid>` 출력 예: `Angle: 0.0° Mech: 0.0° … Range:0-180°`. 단 **`--session-timeout`을 무시하고 `--timeout`까지 대기**합니다. 따라서 첫 줄을 읽은 뒤 프로세스를 직접 종료해야 합니다. | M3 |
| 자세 설정 CLI | 없음. `simctl ui` 옵션은 appearance, increase_contrast, content_size뿐입니다. | M4 |
| 자세 설정 UI | Xcode 27.1 Device Hub 하단 버튼으로 open, close, rotate, fold를 할 수 있습니다(S1 1:17). ⌥ 키를 누르면 힌지 각도 슬라이더가 나옵니다(T2). 구버전 Device Hub가 실행되면 위젯이 보이지 않을 수 있습니다(T7). | — |

## 레이어 설계

### L1. Snapshot 매트릭스 (CI 가능)
- 대상: 실험 01, 01-b, 07처럼 **폭과 size class 비교**가 핵심인 화면
- 방법: `ImageRenderer` 또는 swift-snapshot-testing으로 trait 조합(`horizontalSizeClass`, 컨테이너 크기)을 렌더링합니다.
  - 기준 크기: 466×678, 678×466, 669×951, 951×669, Split View 추정치, PiP 추정치
- 한계: 실제 힌지, `ArrangementView`의 자세별 배치, reserved region, 세로 바는 **재현되지 않습니다**.

### L2. 시뮬레이터 캡처 스크립트 (`tools/duo-capture/capture.sh`)

```
for experiment in experiments:
  simctl openurl <udid> duolab://experiment/<id>?overlay=1
  for pose in poses:           # closed, open, half(book), half(laptop) …
    set_pose(pose)             # (a) Device Hub AX helper  (b) 반자동: 안내 후 대기
    wait_hinge_stable(±0.5°, 2회)   # devicectl hinge-angle 첫 줄만 읽고 kill
    for display in outer inner:
      simctl io <udid> screenshot --display=$UUID --mask=black \
        docs/images/<exp>/<pose>-<orientation>-<display>.png
```

자세를 설정하는 방법 후보를 비교하면 다음과 같습니다.

| 방법 | 장점 | 단점 |
|------|------|------|
| (a) callstack/agent-device `fold` | 이미 구현되어 있습니다(T5). | 외부 의존성(npm)이 생기고, Device Hub UI가 바뀌면 깨질 수 있습니다. |
| (b) 자체 AX 헬퍼 (osascript 또는 Swift `AXUIElement`) | 의존성이 없고 필요한 동작만 넣을 수 있습니다. | 터미널에 **손쉬운 사용 권한**을 줘야 하고, 버튼 식별자를 조사해야 합니다. |
| (c) 반자동 | 가장 안정적입니다. 사람이 자세를 바꾸면 스크립트가 각도 변화를 감지해 자동 캡처합니다. | 사람이 있어야 합니다. |

권장 순서: **먼저 (c)로 바로 사용**하고, 이어서 (b)를 시도합니다. (b)가 안정적으로 동작하면 전환합니다.

### L3. XCUITest (회전과 앱 내부 상태)
- `XCUIDevice.shared.orientation`으로 회전하고, popup 열기 같은 인터랙션 후 `XCTAttachment(screenshot:)`을 남깁니다.
- `xcrun xcresulttool export attachments`로 추출해 `docs/images`에 복사합니다.
- 자세는 L2와 같은 방식으로 외부에서 설정합니다.

## 미확인·조사 필요
- Split View(1/2)와 PiP 상단 고정을 자동화할 수 있는가? 현재 CLI로는 불가능해 보입니다. 앱 측에서 `UIWindowScene` 크기 요청으로 흉내 낼 수 있는지도 확인해야 합니다.
- Device Hub의 AX 트리에서 posture 버튼의 identifier.
- 캡처 이미지의 방향: 가로 자세에서 framebuffer가 회전된 상태로 저장되는지 여부.

## 출처
S1(1:17), D11, M1–M4, T2, T5, T6, T7
