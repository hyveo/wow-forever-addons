# 변경 내역

## 1.1.0 — 2026-11-21

- Now in 9 languages: English, 한국어, Deutsch, Español (América Latina / España), Français, Português, Русский, 简体中文, 繁體中文
- Uses the language chosen in hyveo Addon Center; without the center it follows your game language
- Text without a translation is shown in English

**한국어**

- 9개 언어 지원: English, 한국어, Deutsch, Español (América Latina / España), Français, Português, Русский, 简体中文, 繁體中文
- hyveo 애드온 센터에서 고른 언어를 따라가요. 센터가 없으면 게임 언어로 나와요
- 번역이 없는 문구는 영어로 보여요

## 1.0.3 — 2026-11-20

- 미니맵 버튼 추가: 왼쪽 클릭 = 상세 창, 오른쪽 클릭 = 정보 바 보이기/숨기기, 드래그로 위치 이동 (`/lp 미니맵`으로 숨기기)

## 1.0.2 — 2026-11-20

- 퀘스트를 완료하거나 경험치가 한 번에 크게 들어왔을 때 "레벨업까지" 시간이 갑자기 줄었다가 다시 늘어나던 문제 수정
- 꾸준히 들어오는 사냥 경험치는 최근 10분으로, 퀘스트처럼 한 번에 크게 들어오는 경험치는 최근 60분에 나눠서 계산

## 1.0.1 — 2026-11-19

- 애드온 목록에 아이콘 표시 (`icon.tga`)
- hyveo 애드온 센터에서 정보 바를 켜고 끄거나 잠글 수 있도록 공개 API(`LevelPace`) 추가

## 1.0.0 — 2026-11-19

- 첫 버전
- 정보 바: 레벨, 경험치 %, 시간당 경험치, 레벨업까지 남은 시간 (휴식 경험치 표시, 드래그 이동, 잠금)
- 상세 창 (`/lp`): 세션 통계, 최근 10분 속도, 퀘스트/사냥 경험치 구분, 남은 사냥 수, 레벨별 소요 시간 기록
- 한국어 / 영어 지원
- 포에버(한밤 기반)의 비밀 값(secret value)을 만나면 계산을 건너뛰도록 처리
