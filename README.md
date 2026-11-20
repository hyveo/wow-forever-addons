# WoW Forever Addons

**English** | [한국어](#wow-forever-애드온-모음-한국어)

[![GitHub stars](https://img.shields.io/github/stars/hyveo/wow-forever-addons?style=social)](https://github.com/hyveo/wow-forever-addons/stargazers) [![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

A collection of addons for World of Warcraft: Forever.
Each addon is one folder under `addons/`, and each one is versioned and released separately.

⭐ **If these addons are useful to you, please star this repo** (the Star button at the top right). It helps other players find them and keeps me going.

## Why 💛

These addons started as things I made for my husband, who plays WoW Forever. 🧙‍♂️⚔️
I don't play myself, but every time he said "I wish there were an addon for this," I made one, and they grew into a collection.
I'm sharing them in case they help you too. ✨

## Addons

| Addon | Description | Get it |
|---|---|---|
| [LevelPace (레벨페이스)](addons/LevelPace) | Leveling helper: XP per hour and time to next level | [CurseForge](https://www.curseforge.com/wow/addons/levelpace) · [zip](../../releases) |
| [CenterBar (센터바)](addons/CenterBar) | Up to 18 action buttons around your character | [CurseForge](https://www.curseforge.com/wow/addons/centerbar) · [zip](../../releases) |
| [HyveoCenter (hyveo 애드온 센터)](addons/HyveoCenter) | Manage the addons above in one in-game window | [CurseForge](https://www.curseforge.com/wow/addons/hyveo-addon-center-hyveo) · [zip](../../releases) |

All three are **available on CurseForge.** Screenshots and details are also at [hyveo.github.io/addons](https://hyveo.github.io/addons/).

## Supported languages

| Language | Game client | CenterBar | LevelPace | HyveoCenter |
|---|---|:-:|:-:|:-:|
| English | enUS / enGB | ✅ | ✅ | ✅ |
| 한국어 (Korean) | koKR | ✅ | ✅ | ✅ |
| Deutsch (German) | deDE | ✅ | ✅ | ✅ |
| Español — América Latina | esMX | ✅ | ✅ | ✅ |
| Español — España | esES | ✅ | ✅ | ✅ |
| Français (French) | frFR | ✅ | ✅ | ✅ |
| Português (Portuguese) | ptBR | ✅ | ✅ | ✅ |
| Русский (Russian) | ruRU | ✅ | ✅ | ✅ |
| 简体中文 (Simplified Chinese) | zhCN | ✅ | ✅ | ✅ |
| 繁體中文 (Traditional Chinese) | zhTW | ✅ | ✅ | ✅ |

- By default the addons follow your game language. Pick a language in hyveo Addon Center (`/hv`) and CenterBar and LevelPace use it too. CenterBar can also have its own language in its options window.
- Text without a translation is shown in English.
- Found a wrong or awkward translation? Please open an [issue](../../issues).

## Addon requests welcome

If there is an addon you wish existed while playing WoW Forever, let us know.
Requests to fix an existing addon that does not run on the Forever client are welcome too.

Leave requests as an [issue](../../issues/new?template=addon-request.md).

What to include:

- **What you want**: what the addon should do, and in which situation
- **Reference addon**: the name and link of a similar existing addon, if there is one
- **What goes wrong**: for a fix request, the error message or a screenshot

## Install

### Option 1. CurseForge app (recommended)

1. In the [CurseForge app](https://www.curseforge.com/download/app), pick World of Warcraft and set the game version to **WoW Forever**.
2. Search for `LevelPace`, `CenterBar` or `hyveo`, or open the CurseForge links in the table above.
3. Click **Install**. The app also tells you about updates.

### Option 2. Download the zip

1. Download the zip of the addon you want from [Releases](../../releases).
2. Unzip it and put the resulting folders into `World of Warcraft\_forever_\Interface\AddOns\`.
   If an older version is there, delete those folders first.
3. Restart the game completely (`/reload` does not re-read the TOC).

Your settings stay either way. They are saved in the `WTF` folder, not in the addon folder.

## Repository layout

```
addons/<addon>/           one addon = one folder (the unit of release)
  <game folder>/          a folder with a .toc = a folder that goes into AddOns
  README.md, CHANGELOG.md
scripts/package.sh        builds the release zip
scripts/bump-interface.sh adds an Interface number to every TOC
.github/workflows/        releases automatically when a tag is pushed
```

## Maintenance

**When a Forever patch makes addons show as "Incompatible"**

```bash
# Check the number in game with /dump select(4, GetBuildInfo()), then
scripts/bump-interface.sh 16003
```

**Releasing a new version**

Create a release on GitHub. Tag names follow `<addon folder>-v<version>` (for example `LevelPace-v1.0.3`).
GitHub Actions zips only that addon, replaces `@project-version@` in the TOC with the version, attaches it to the Release, and uploads it to CurseForge.
See [docs/RELEASING.md](docs/RELEASING.md) for the steps.
To build only the zip locally, run `scripts/package.sh LevelPace 1.0.1` (output: `dist/`).

## Sponsor

If an addon helped you, please sponsor via [GitHub Sponsors](https://github.com/sponsors/hyveo).
Sponsorship goes toward making new addons and keeping up with Forever patches.

[![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

## License

All Rights Reserved. Using the addons and sending bug reports or pull requests is welcome; redistribution and code reuse need permission. See [LICENSE](LICENSE). Made by @hyveo

---

# WoW Forever 애드온 모음 (한국어)

[English](#wow-forever-addons) | **한국어**

[![GitHub stars](https://img.shields.io/github/stars/hyveo/wow-forever-addons?style=social)](https://github.com/hyveo/wow-forever-addons/stargazers) [![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

World of Warcraft: Forever(와우 포에버)에서 쓰는 애드온 모음입니다.
애드온 하나가 `addons/` 아래 폴더 하나이고, 버전과 배포는 애드온별로 따로 관리합니다.

⭐ **유용했다면 오른쪽 위의 Star를 눌러 주세요.** 다른 분들이 이 애드온을 찾는 데 도움이 되고, 계속 만드는 힘이 돼요.

## 만든 이유 💛

와우 포에버를 하는 남편을 위해 만들기 시작한 애드온이에요. 🧙‍♂️⚔️
저는 게임을 하지 않지만, 남편이 "이런 게 있으면 좋겠다"고 할 때마다 하나씩 만들다 보니 모음이 됐어요.
같은 불편을 겪는 분들도 편하게 쓰셨으면 해서 공개합니다. ✨

## 애드온 목록

| 애드온 | 설명 | 받는 곳 |
|---|---|---|
| [레벨페이스 (LevelPace)](addons/LevelPace) | 시간당 경험치와 레벨업까지 남은 시간을 보여주는 레벨링 도우미 | [CurseForge](https://www.curseforge.com/wow/addons/levelpace) · [zip](../../releases) |
| [센터바 (CenterBar)](addons/CenterBar) | 캐릭터 양옆에 액션 버튼을 최대 18개 배치 | [CurseForge](https://www.curseforge.com/wow/addons/centerbar) · [zip](../../releases) |
| [hyveo 애드온 센터 (HyveoCenter)](addons/HyveoCenter) | 위 애드온들을 게임 안에서 한 창으로 켜고 끄고 설정 | [CurseForge](https://www.curseforge.com/wow/addons/hyveo-addon-center-hyveo) · [zip](../../releases) |

세 애드온 모두 **CurseForge에서 받을 수 있어요.** 애드온 소개와 예시 화면은 [hyveo.github.io/addons](https://hyveo.github.io/addons/)에도 있습니다.

## 지원 언어

| 언어 | 게임 클라이언트 | 센터바 | 레벨페이스 | 애드온 센터 |
|---|---|:-:|:-:|:-:|
| English (영어) | enUS / enGB | ✅ | ✅ | ✅ |
| 한국어 | koKR | ✅ | ✅ | ✅ |
| Deutsch (독일어) | deDE | ✅ | ✅ | ✅ |
| Español — América Latina (스페인어, 중남미) | esMX | ✅ | ✅ | ✅ |
| Español — España (스페인어, 스페인) | esES | ✅ | ✅ | ✅ |
| Français (프랑스어) | frFR | ✅ | ✅ | ✅ |
| Português (포르투갈어) | ptBR | ✅ | ✅ | ✅ |
| Русский (러시아어) | ruRU | ✅ | ✅ | ✅ |
| 简体中文 (중국어 간체) | zhCN | ✅ | ✅ | ✅ |
| 繁體中文 (중국어 번체) | zhTW | ✅ | ✅ | ✅ |

- 기본은 게임 언어를 따라가요. hyveo 애드온 센터(`/hv`)에서 언어를 고르면 센터바·레벨페이스도 같은 언어를 써요. 센터바는 설정 창에서 따로 고를 수도 있어요.
- 번역이 없는 문구는 영어로 보여요.
- 번역이 틀리거나 어색하면 [이슈](../../issues)로 알려 주세요.

## 애드온 요청 받습니다

와우 포에버를 하면서 "이런 애드온 있었으면 좋겠다" 싶은 게 있으면 알려 주세요.
포에버 클라이언트에서 안 돌아가는 기존 애드온을 고쳐 달라는 요청도 좋습니다.

요청은 [Issues](../../issues/new?template=addon-request.md)에 남겨 주세요.

남겨 주실 내용:

- **원하는 기능**: 어떤 상황에서 무엇을 해 주면 좋은지
- **참고 애드온**: 비슷한 기존 애드온이 있다면 이름과 링크
- **안 될 때 화면**: 기존 애드온 수정 요청이면 오류 메시지나 스크린샷

## 설치

### 방법 1. CurseForge 앱 (추천)

1. [CurseForge 앱](https://www.curseforge.com/download/app)에서 World of Warcraft를 고르고, 게임 버전을 **WoW Forever**로 맞춥니다.
2. `레벨페이스`, `센터바`, `hyveo`로 검색하거나 위 표의 CurseForge 링크를 엽니다.
3. **Install**을 누릅니다. 업데이트도 앱이 알려 줍니다.

### 방법 2. zip을 받아 직접 넣기

1. [Releases](../../releases)에서 원하는 애드온의 zip을 받습니다.
2. 압축을 풀어 나온 폴더를 `World of Warcraft\_forever_\Interface\AddOns\` 에 넣습니다.
   이전 버전이 있으면 해당 폴더를 지우고 새로 넣으세요.
3. 게임을 완전히 재시작합니다 (`/reload`로는 TOC가 다시 읽히지 않습니다).

어느 방법으로 바꿔 설치해도 설정은 그대로 남습니다. 설정은 애드온 폴더가 아니라 `WTF` 폴더에 저장됩니다.

## 레포 구조

```
addons/<애드온>/          애드온 1개 = 폴더 1개 (배포 단위)
  <게임 폴더>/            .toc가 들어 있는 폴더 = 실제로 AddOns에 들어가는 폴더
  README.md, CHANGELOG.md
scripts/package.sh        배포용 zip 생성
scripts/bump-interface.sh 모든 TOC의 Interface 번호 일괄 추가
.github/workflows/        태그 push 시 자동 릴리스
```

## 관리 방법

**포에버 패치로 "미호환"이 뜰 때**

```bash
# 게임에서 /dump select(4, GetBuildInfo()) 로 번호 확인 후
scripts/bump-interface.sh 16003
```

**새 버전 배포**

GitHub에서 릴리즈를 만들면 됩니다. 태그 이름은 `<애드온폴더명>-v<버전>` (예: `LevelPace-v1.0.3`)입니다.
GitHub Actions가 해당 애드온만 zip으로 묶고, TOC의 `@project-version@`을 버전으로 바꿔 Release에 붙인 뒤 CurseForge에도 올립니다.
자세한 순서는 [docs/RELEASING.md](docs/RELEASING.md)를 보세요.
로컬에서 zip만 만들려면 `scripts/package.sh LevelPace 1.0.1` (결과: `dist/`).

## 후원

애드온이 도움이 됐다면 [GitHub Sponsors](https://github.com/sponsors/hyveo)로 후원해 주세요.
후원은 새 애드온 제작과 포에버 패치 대응에 쓰입니다.

[![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

## 라이선스

All Rights Reserved. 게임에서 쓰는 것과 버그 제보·수정 제안은 자유지만, 허락 없는 재배포와 코드 재사용은 허용하지 않습니다. 자세한 내용은 [LICENSE](LICENSE)를 보세요. 만든 사람: @hyveo
