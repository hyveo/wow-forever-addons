# 센터바 (CenterBar)

<img src="docs/icon.png" alt="센터바 아이콘" width="120">

캐릭터 양옆에 액션 버튼을 최대 18개 놓아 주는 와우 포에버 애드온입니다. 시선을 화면 가운데에 둔 채로 기술을 쓸 수 있어요.

- **만든 사람:** @hyveo
- **소스 / 버그 제보:** https://github.com/hyveo/wow-forever-addons ([이슈 남기기](https://github.com/hyveo/wow-forever-addons/issues))

## 받는 곳

- **CurseForge (추천):** <https://www.curseforge.com/wow/addons/centerbar> — CurseForge 앱에서 게임 버전을 WoW Forever로 맞추고 `센터바`로 검색해도 나와요.
- **zip:** [Releases](../../../../releases)에서 `CenterBar-버전.zip`을 받아 `Interface\AddOns\`에 넣어요.

## 기능

- 버튼 6 / 12 / 18개 중 선택 (캐릭터에서 가까운 열부터 늘어남)
- 배치: 기본 / 둥글게(캐릭터를 감싸는 호) / 세로 3줄 1~3 — 예전 센터바와 같은 자리
- 슬롯 1~5: 슬롯마다 넣은 기술(주문·아이템·매크로)을 센터바가 따로 저장해요. 다른 액션바와 섞이지 않고, 특성마다 쓰는 슬롯을 기억해요
- 빈 칸 테두리(격자) 보이기, 아이콘이 칸을 꽉 채우는 예전 퀵슬롯 모양
- 투명도 + 복구 조건: 전투 시 / 대상 선택 시 / 마우스오버 시 또렷하게
- 탈것 탑승 시 숨김, 빈 버튼 항상 표시
- 배율, 투명도, 이동간격 슬라이더
- 설정 창을 열면 화면 전체 격자가 나와서, 번호 칸을 끌어 버튼을 하나씩 옮길 수 있어요 (대칭 이동)
- 위치 잠금 해제 후 드래그로 옮기기
- 버튼 툴팁 끄기
- 단축키 지정 (게임 메뉴 → 단축키 설정 → 애드온 → 센터바)
- 재사용 대기시간·충전 횟수·사용 가능 여부는 게임 기본 액션 버튼과 같은 방식으로 표시
- 언어: 한국어, English, Deutsch, Español (América Latina / España), Français, Português, Русский, 简体中文, 繁體中文 — 기본은 hyveo 애드온 센터에서 고른 언어를 따라가고(센터가 없으면 게임 언어), 설정 창에서 센터바만 따로 고를 수도 있어요

## 명령어

| 명령어 | 동작 |
|---|---|
| `/cb` (`/centerbar`, `/센터바`) | 설정 창 열기 |
| `/cb 1` ~ `/cb 5` | 슬롯 바꾸기 (`/cb next` = 다음 슬롯, 단축키도 있음) |
| `/cb lock` (`잠금`) | 위치 잠금/해제 |
| `/cb reset` (`초기화`) | 위치와 설정을 처음으로 |
| `/hv cb` | hyveo 애드온 센터가 있으면 여기서도 열림 |

## 알아두기

- 예전 버전에서 액션바 칸에 넣어 둔 기술은 처음 접속할 때 한 번 자동으로 가져와요.
- 액션바 잠금을 켜 두면 버튼에서 기술을 빼낼 때 Shift를 누른 채 끌어 주세요.
- 전투 중에 바꾼 설정은 전투가 끝나면 적용돼요 (게임 보안 규칙).
- 예전 "중앙버튼" 계열 애드온과 함께 켜면 버튼이 겹치고 `/cb` 명령어도 겹치니 하나만 켜 주세요.

## 번역

Spotted an awkward or wrong translation? Please open a [GitHub issue](https://github.com/hyveo/wow-forever-addons/issues). All strings live in `CenterBar/Locales.lua`.

번역이 어색하거나 틀린 곳이 있으면 [GitHub 이슈](https://github.com/hyveo/wow-forever-addons/issues)로 알려 주세요. 문구는 `CenterBar/Locales.lua` 한 파일에 모여 있어요.

## 문제가 생기면

[GitHub 이슈](https://github.com/hyveo/wow-forever-addons/issues)에 아래 내용을 함께 남겨주세요.

- 애드온 목록에 **미호환**이 뜨면: 게임에서 `/dump select(4, GetBuildInfo())` 결과 번호
- 오류가 나면: `/console scriptErrors 1` 입력 후 다시 재현한 오류 문구
