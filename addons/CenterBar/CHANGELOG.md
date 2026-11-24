# Changelog · 변경 내역

Each version lists English first, then Korean. 버전마다 영어를 먼저, 한국어를 그다음에 적습니다.

## 1.7.1 — 테스트 중

**English**

- Fixed mounts on a button not being summoned when clicked. Click again while mounted to dismount
- Shift + right-click a button to empty it. This always works, including for items that cannot be dragged off

**한국어**

- 버튼에 넣은 탈것이 눌러도 불러지지 않던 문제 수정. 탄 상태에서 다시 누르면 내려요
- 버튼을 Shift + 오른쪽 클릭하면 비워져요. 끌어서 빠지지 않는 아이템도 이 방법으로는 항상 비울 수 있어요

## 1.7.0 — 2026-11-25

**English**

- Error log: if one of hyveo's addons hits an error, it is quietly written down instead of being lost. Open it with `/cb errors`, copy it, and post it in a GitHub issue or a CurseForge comment. It holds no character, realm or account names
- The log covers CenterBar, LevelPace and hyveo Addon Center together, whichever of them you open it from

**한국어**

- 오류 기록: hyveo 애드온에서 오류가 나면 사라지지 않고 조용히 적어 둬요. `/cb 오류`(또는 `/cb errors`)로 열어서 복사한 뒤 GitHub 이슈나 CurseForge 댓글에 올려 주세요. 캐릭터·서버·계정 이름은 들어가지 않아요
- 센터바, 레벨페이스, hyveo 애드온 센터의 오류를 한곳에 모아 보여 줘요. 어느 애드온에서 열어도 같은 기록이에요

## 1.6.0 — 2026-11-25

**English**

- Buttons now accept everything the game's own action bars do: mounts, pets, toys, equipment sets, pet abilities and spell flyouts, as well as spells, items and macros. Drag them on the same way as an item
- Fixed some items (such as the sleeping bag) getting stuck on a button: anything on a button can now always be dragged off

**한국어**

- 게임 기본 단축바에 들어가는 건 센터바 버튼에도 다 들어가요: 주문·아이템·매크로에 더해 탈것, 애완동물, 장난감, 장비 구성, 소환수 기술, 펼침 메뉴 주문까지. 아이템을 넣을 때처럼 끌어다 놓으면 돼요
- 일부 아이템(침낭 등)이 버튼에서 빠지지 않던 문제 수정: 버튼에 넣은 것은 언제든 끌어서 뺄 수 있어요

## 1.5.1 — 2026-11-23

**English**

- Spells placed on CenterBar no longer keep glowing as "not on an action bar" in the spellbook

**한국어**

- 센터바에 올린 주문이 마법책에서 "단축바에 없음"으로 계속 반짝이던 것을 멈췄어요

## 1.5.0 — 2026-11-21

**English**

- The language picker has a new default, "Follow addon center": CenterBar uses the language chosen in hyveo Addon Center
- You can still pick "Auto" (game language) or a specific language just for CenterBar
- Without the addon center installed, it works as before (default is the game language)

**한국어**

- 언어 선택에 새 기본값 "애드온 센터 따름" 추가: hyveo 애드온 센터에서 고른 언어를 센터바도 따라가요
- 센터바만 따로 "자동"(게임 언어)이나 특정 언어로 고를 수도 있어요
- 애드온 센터가 없으면 예전처럼 게임 언어가 기본이에요

## 1.4.1 — 2026-11-21

**English**

- Options window: in languages with long labels (German, for example), checkbox text now wraps instead of running outside the window. The window width is unchanged
- Fixed the two help lines at the bottom overlapping, and added space between the help text and the bottom buttons
- The bottom buttons (Reset, Close) are larger, and grow wider when their text is long

**한국어**

- 설정 창: 독일어처럼 문구가 긴 언어에서는 체크박스 글자가 줄바꿈돼서 창 밖으로 나가지 않아요 (창 너비는 그대로)
- 설정 창 아래 도움말 두 줄이 겹치던 것 수정, 도움말과 아래 버튼 사이를 넓혔어요
- 아래 버튼(처음으로·닫기)을 더 크고 넉넉하게, 글자가 길면 버튼도 넓어져요

## 1.4.0 — 2026-11-21

**English**

- Multi-language support: 한국어, English, Deutsch, Español (América Latina / España), Français, Português, Русский, 简体中文, 繁體中文
- Added a language picker at the bottom left of the options window. The default is "Auto" (follows the game language); a change applies after the UI reloads and is saved account-wide
- Names and descriptions on the keybinding screen and in the addon list also use the chosen language
- Text without a translation is shown in English

**한국어**

- 다국어 지원: 한국어, English, Deutsch, Español (América Latina / España), Français, Português, Русский, 简体中文, 繁體中文
- 설정 창 왼쪽 아래에 언어 선택 추가. 기본값은 "자동"(게임 언어를 따라감)이고, 바꾸면 UI를 다시 불러온 뒤 적용돼요. 계정 전체에 저장돼요
- 단축키 설정 화면과 애드온 목록의 이름·설명도 고른 언어로 나와요
- 번역이 없는 문구는 영어로 보여요

## 1.3.7 — 2026-11-19

- 버튼 툴팁의 기술 이름 오른쪽에 스킬 레벨("2 레벨")이 기본 액션바처럼 표시돼요 (#26)

## 1.3.6 — 2026-11-19

- 버튼 툴팁이 스킬북에서 볼 때와 같은 내용으로 나와요 (배운 스킬 레벨 포함) (#26)

## 1.3.5 — 2026-11-19

- 슬롯 5개: 슬롯마다 넣은 기술(주문·아이템·매크로)을 센터바가 따로 저장해요. 다른 액션바와 섞이지 않고, 특성마다 쓰는 슬롯을 기억해요 (`/cb 1` ~ `/cb 5`, "다음 슬롯" 단축키)
- 배치 5종(기본, 둥글게, 세로 3줄 1~3)과 화면 격자에서 버튼을 하나씩 끌어 옮기기 (대칭 이동)
- 배율·투명도·이동간격 슬라이더, 가로·세로 위치 미세 조정
- 투명도 복구 조건: 전투 시 / 대상 선택 시 / 마우스오버 시 또렷하게
- 탈것 탑승 시 숨김, 빈 버튼 항상 표시, 툴팁 숨김, 채팅창 메시지 숨김
- 미니맵 버튼: 왼쪽 클릭 = 설정 창, 오른쪽 클릭 = 다음 슬롯
- 아이콘이 칸을 꽉 채우고, 빈 칸에는 옅은 테두리만 보여요
- 버튼에 기술을 넣을 때 뜨던 "기능이 차단되었습니다" 오류와 재사용 대기시간 오류 수정
- 예전에 액션바 칸에 넣어 둔 기술은 처음 접속할 때 한 번 자동으로 가져와요

## 1.0.1 — 2026-11-19

- 설정 창 명령어를 `/cb`로 변경 (`/centerbar`, `/센터바`도 그대로 동작, `/cbar`는 제거)

## 1.0.0 — 2026-11-19

- 첫 버전 (처음부터 새로 만든 센터바)
- 버튼 최대 18개, 표시 개수 6/12/18
- 특성별 액션바 페이지, 13~18번 추가 페이지
- 보이기 방식(항상/전투 중/마우스 올렸을 때), 크기·투명도·간격·거리, 위치 잠금, 툴팁 끄기
- 단축키 18개, 설정 창(`/센터바`)
- hyveo 애드온 센터용 공개 API(`CenterBar`)
