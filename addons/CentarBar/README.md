# 중앙버튼 (CentarBar) — Forever 대응판

화면 가운데에 액션 버튼 12개를 만들어 주는 애드온입니다. 와우 포에버 정식 클라이언트에서 동작하도록 수정했습니다.

- **원작:** Clamp, zico
- **Forever 대응 수정:** @hyveo

## 버전별 변경 화면 (예시)

**1.61** — 포에버 정식 클라이언트에서 미호환으로 로드되지 않던 문제 수정

![1.61 수정 전후](docs/v1.61-before-after.png)

## 구성

| 폴더 | 역할 |
|---|---|
| `CentarBar` | 본체 (버튼 12개, 단축키) |
| `CentarBar_Option` | 설정 창 |

두 폴더를 모두 `Interface\AddOns\` 에 넣어야 합니다.

## 명령어

`/cbo`, `/cb`, `/centarbar`, `/센타`, `/중앙바` — 설정 창 열기

단축키: 게임 메뉴 → 단축키 설정 → 애드온 → CENTARBAR

## 문제가 생기면

- 애드온 목록에 **미호환**이 뜨면: 게임에서 `/dump select(4, GetBuildInfo())` 결과 번호를 알려주세요 (TOC의 Interface 번호 문제).
- 오류가 나면: `/console scriptErrors 1` 입력 후 다시 재현하고 오류 문구를 이슈로 남겨주세요.

변경 내역은 [CHANGELOG.md](CHANGELOG.md)를 참고하세요.
