# 릴리즈 올리는 방법

GitHub에서 릴리즈를 하나 만들면 zip 만들기, GitHub 릴리즈 첨부, CurseForge 업로드까지 자동으로 돼요.
CurseForge에는 따로 올리지 않아도 됩니다.

## 한눈에 보기

1. 코드를 `main`에 올린다
2. `CHANGELOG.md`에 새 버전 항목을 적는다
3. GitHub에서 릴리즈를 만든다 (태그: `애드온폴더명-v버전`)
4. 1~2분 뒤 결과를 확인한다

## 버전 규칙

버전은 `큰 변화.기능.수정` 형식이에요 (예: `1.4.1`). 애드온마다 따로 올려요.

| 자리 | 올리는 때 | 예시 |
|---|---|---|
| 세 번째 (수정) | 버그 수정, 문구·번역 수정, 화면 다듬기. 쓰는 방법은 그대로일 때 | 1.4.1 → 1.4.2 |
| 두 번째 (기능) | 기능 추가. 기존 설정과 저장 내용은 그대로 유지될 때 | 1.4.1 → 1.5.0 |
| 첫 번째 (큰 변화) | 기존 설정이 초기화되거나 쓰는 방법이 크게 바뀔 때 | 1.5.0 → 2.0.0 |

**꼭 지킬 것**

1. **고치기 시작할 때 다음 버전 번호를 먼저 정해요.** `CHANGELOG.md` 맨 위에 `## 1.6.0 — 테스트 중` 항목을 만들고 시작해요.
   그러면 테스트 zip이 `CenterBar-1.6.0-dev-…`로 나와서, 어느 버전을 준비하는 빌드인지 이름만 봐도 알 수 있어요.
   테스트가 끝난 빌드에 태그(`CenterBar-v1.6.0`)를 달면 그게 정식 1.6.0이 돼요. 이때 제목의 `테스트 중`을 날짜로 바꿔요.
2. **릴리즈 전에 고친 내용은 같은 버전 항목에 덧붙여요.** 테스트하다 고칠 게 생겨도 번호를 올리지 않아요.
   `CHANGELOG.md` 맨 위 항목이 아직 릴리즈되지 않았다면, 새 항목을 만들지 말고 그 항목을 고쳐요.
   수정만 하려고 `1.5.2`로 시작했는데 테스트 중에 기능이 추가되면, 아직 배포 전이니 그 항목의 번호를 `1.6.0`으로 바꿔요.
3. **테스트는 `-dev-` zip으로 해요.** PR을 올리거나 `main`에 병합하면 `CenterBar-1.5.0-dev-a1b2c3d` 같은 테스트 zip이 자동으로 만들어져요. 이 zip은 GitHub 릴리즈와 CurseForge에 올라가지 않아요.
4. **한 번 릴리즈한 번호는 다시 쓰지 않아요.** 릴리즈 후에 고칠 게 나오면 다음 번호로 올려요.
5. **`0.x`는 "아직 다듬는 중"이라는 뜻이에요.** 공개해서 쓰기에 안정됐다고 보면 `1.0.0`으로 올려요.

**맨 위 항목이 릴리즈됐는지 확인하는 법**

[Releases](https://github.com/hyveo/wow-forever-addons/releases)에 `<애드온폴더명>-v<버전>` 태그가 있으면 릴리즈된 거예요. 없으면 아직 테스트 중인 번호예요.

> 이 규칙이 생긴 이유: 센터바 1.4.0은 릴리즈 전에 테스트하다 고칠 게 나오자 1.4.1로 번호를 올려서, 1.4.0이 한 번도 배포되지 않은 채 건너뛰어졌어요.
> 번호를 먼저 정하는 이유: 테스트 zip에 마지막 정식 버전 번호(`1.5.1-dev-…`)가 붙으면 정식 1.5.1과 헷갈려요.

## 자동 검사

코드가 바뀔 때마다, 그리고 릴리즈할 때마다 자동 검사가 돌아요. 통과하지 못하면 테스트 zip도 안 만들어지고 배포도 안 돼요.

| 검사 | 막아 주는 것 |
|---|---|
| 문법 (Lua 5.1) | 문법 오류로 게임에서 애드온이 통째로 안 켜지는 일 |
| TOC 파일 목록 | TOC에 적힌 파일이 zip에 빠지는 일 |
| 공용 파일 일치 | `ErrorLog.lua`가 세 애드온에서 서로 달라지는 일 |
| 시나리오 | 가짜 게임 환경에서 애드온을 돌려, 원래 되던 동작이 깨지는 일 |

- 직접 돌리기: `pip install lupa` 후 `python3 tests/run_tests.py`
- 동작을 일부러 바꿨으면 기대 결과도 고쳐요: `python3 tests/run_tests.py --update` 후 `tests/expected/`의 바뀐 내용을 확인하고 같이 올려요.
- **한계**: 실제 게임에서 돌려 보는 건 아니에요. 게임이 예상과 다르게 동작하는 문제는 못 잡아요. 그래서 아래 베타 단계가 있어요.

## 베타로 먼저 올리기

게임에서 아직 확인하지 못한 버전은 **베타**로 먼저 올려요. 베타는 CurseForge 앱에서 베타 받기를 켠 사람에게만 보여요. 다른 유저는 마지막 정식 버전을 그대로 써요.

1. GitHub에서 릴리즈를 만들 때 **Set as a pre-release**를 체크해요. 이러면 CurseForge에 베타로 올라가요.
2. 베타를 받아 게임에서 확인해요.
3. 문제가 없으면 정식으로 바꿔요.
   - CurseForge: [작성자 페이지](https://authors.curseforge.com/#/projects) → 프로젝트 → Files → 파일 줄 오른쪽의 연필 → **Release Type**을 `Release`로 → Submit
   - GitHub: 릴리즈 편집에서 **Set as a pre-release** 체크를 풀어요.
4. 문제가 있으면 고쳐서 다음 번호로 다시 베타를 올려요. 한 번 올린 번호는 다시 쓰지 않아요.

**베타 받는 방법 (CurseForge 앱)**

- 내 애드온 목록에서 해당 애드온을 오른쪽 클릭하고 **Release Type**을 `Beta`로 바꿔요. 그 애드온만 베타를 받게 돼요.
- 메뉴가 안 보이면 CurseForge 웹사이트의 애드온 페이지 → **Files** 탭에서 `B` 표시가 붙은 파일을 직접 받아 `Interface\AddOns\`에 넣어요.

## 0. 배포 전에 테스트 zip 받기

`main`에 코드가 들어가거나 PR이 올라오면 **테스트용 zip이 자동으로 만들어져요.** 배포(GitHub 릴리즈, CurseForge)는 되지 않아요.

1. [Actions](https://github.com/hyveo/wow-forever-addons/actions)에서 `Build addons (test zip)` 실행을 열어요.
2. 맨 아래 **Artifacts**에서 `CenterBar-1.4.0-dev-a1b2c3d` 같은 이름을 눌러 받아요. (GitHub에 로그인해야 받을 수 있어요)
3. 풀면 나오는 폴더(예: `CenterBar/`)를 `Interface\AddOns\`에 넣고 게임에서 확인해요.

- 버전 이름은 `CHANGELOG 맨 위 버전-dev-커밋 7자리`예요. 게임 애드온 목록에도 이 버전으로 보여요.
- 파일은 30일 동안 남아요. Actions 화면에서 `Run workflow`를 눌러 아무 때나 다시 만들 수도 있어요.
- 확인이 끝나면 아래 순서대로 태그를 달아 배포해요.
- **바뀐 애드온만 만들어져요.** 센터바만 고쳤으면 센터바 zip만 나와요. 묶는 스크립트(`scripts/`)를 고쳤거나 `Run workflow`로 직접 실행하면 세 애드온을 모두 만들어요.

## 1. 올리기 전에

- 바꾼 코드가 `main` 브랜치에 들어가 있어야 해요. 릴리즈는 그 시점의 `main`을 묶어요.
- 해당 애드온의 `CHANGELOG.md` 맨 위에 새 버전 항목을 적어요. 이 내용이 GitHub 릴리즈 설명과 CurseForge 변경 내역으로 그대로 들어가요.

```markdown
## 1.3.6 — 2026-11-20

**English**

- One line per change, written as the result

**한국어**

- 바뀐 점을 결과 중심으로 한 줄씩
```

- **영어를 먼저, 한국어를 그다음에 적어요.** CurseForge와 GitHub 릴리즈에 이 순서 그대로 올라가요.

- 항목이 없으면 설명이 빈 채로 올라가요.
- TOC 파일의 버전은 고치지 않아도 돼요. `@project-version@` 자리에 태그의 버전이 자동으로 들어가요.

## 2. 태그 이름 규칙

`애드온폴더명-v버전` 형식이에요. 폴더명은 대소문자까지 맞아야 하고 `-v`가 꼭 들어가야 해요.

| 애드온 | 태그 예시 | CurseForge 프로젝트 ID |
|---|---|---|
| 센터바 | `CenterBar-v1.3.6` | 1814948 |
| 레벨페이스 | `LevelPace-v1.0.2` | 1814884 |
| hyveo 애드온 센터 | `HyveoCenter-v0.2.0` | 1814965 |

형식이 틀리면 자동화가 시작되지 않아요. 오류도 안 뜨고 아무 일도 안 일어나요.

## 3. GitHub에서 릴리즈 만들기

1. <https://github.com/hyveo/wow-forever-addons/releases> 에서 **Draft a new release**를 눌러요.
2. **Choose a tag**에 새 태그(예: `CenterBar-v1.3.6`)를 입력하고 **Create new tag**를 골라요.
3. **Target**은 `main` 그대로 둬요.
4. 제목과 설명은 비워 둬도 돼요. 자동으로 채워져요.
5. **Set as a pre-release**: 게임에서 확인하지 못한 버전이면 체크해요(베타로 올라감). 확인이 끝난 버전이면 체크하지 않아요.
6. **Publish release**를 눌러요.

## 4. 자동으로 되는 일

릴리즈를 만들면 `.github/workflows/release.yml`이 실행돼요.

0. 자동 검사를 돌려요. 실패하면 여기서 멈춰요.
1. 태그에서 애드온 이름과 버전을 읽어요.
2. 그 애드온만 zip으로 묶어요 (`CenterBar-1.3.6.zip`).
3. `CHANGELOG.md`에서 해당 버전 항목을 뽑아 릴리즈 설명으로 넣어요.
4. zip을 GitHub 릴리즈에 붙여요.
5. 같은 zip을 CurseForge 프로젝트에 올려요. 게임 버전은 1.60.1(WoW Forever)이에요. pre-release로 만든 릴리즈는 베타로, 아니면 정식으로 올라가요.
6. 디스코드 채널에 배포 알림을 보내요.

## 디스코드 알림

배포하면 애드온별 디스코드 채널에 알림이 자동으로 가요.

| 언제 | 알림 내용 |
|---|---|
| 베타로 배포 | 버전, "베타", 변경 내역, 반영된 이슈·요청(번호와 제목), 자세한 수정 내용, 확인해 볼 것, 받는 곳 |
| 정식으로 배포 | 버전, "정식", 변경 내역, 반영된 이슈·요청, 자세한 수정 내용, 확인해 볼 것, 받는 곳 |
| 베타를 정식으로 전환 | "베타였던 버전이 CurseForge에 정식으로 릴리즈됐다"는 알림 |

- **자세한 수정 내용**과 **확인해 볼 것**은 `addons/<애드온>/notes/<버전>.md` 파일에서 가져와요 (예: `addons/CenterBar/notes/1.7.2.md`). 릴리즈하기 전에 이 파일을 만들어요. 없으면 그 두 칸만 빠진 채로 알림이 가요.

  ```markdown
  ## 자세한 수정 내용

  - **증상**: 무엇이 어떻게 잘못됐는지
  - **원인**: 왜 그랬는지
  - **수정**: 어떻게 고쳤는지, 달라지는 점

  ## 확인해 볼 것

  - 게임에서 직접 해 볼 것을 한 줄에 하나씩
  ```

  이 파일은 디스코드 알림에만 쓰여요. CurseForge와 GitHub 릴리즈 설명에는 `CHANGELOG.md`의 짧은 변경 내역이 들어가요. zip에도 들어가지 않아요.
- **반영된 이슈**는 앞 버전 이후 그 애드온을 고친 커밋 메시지의 `Refs #번호`, `Fixes #번호`에서 찾아요. 그래서 커밋이나 PR 설명에 이슈 번호를 꼭 적어요.
- **정식 전환 알림**은 GitHub 릴리즈 편집에서 **Set as a pre-release** 체크를 풀 때 나가요. CurseForge에서 Release Type을 먼저 `Release`로 바꾼 다음에 체크를 풀어요.
- 웹훅 주소는 저장소 Secrets에 넣어요: `DISCORD_WEBHOOK_CENTERBAR`, `DISCORD_WEBHOOK_LEVELPACE`, `DISCORD_WEBHOOK_HYVEOCENTER`. 웹훅 주소는 아는 사람 누구나 그 채널에 글을 쓸 수 있는 열쇠라서, 코드나 문서에 적지 않아요.
- Secret이 없으면 알림만 건너뛰고 배포는 그대로 돼요.
- 알림을 다시 보내려면 [Actions](https://github.com/hyveo/wow-forever-addons/actions) → `Notify Discord` → **Run workflow**에서 태그와 종류를 골라요.

## 5. 올라갔는지 확인하기

| 어디서 | 무엇을 보면 되나 |
|---|---|
| [Actions](https://github.com/hyveo/wow-forever-addons/actions) | `Release addon` 실행이 초록색 체크인지 |
| [Releases](https://github.com/hyveo/wow-forever-addons/releases) | 새 릴리즈에 zip이 붙었는지 |
| [CurseForge 작성자 페이지](https://authors.curseforge.com/#/projects) | 프로젝트 → Files 탭에 새 파일이 생겼는지 |

CurseForge 업로드가 실패해도 GitHub 릴리즈는 그대로 만들어지고 Actions도 초록색으로 나와요.
그래서 CurseForge Files 탭은 꼭 직접 확인해요. Actions 실행의 `CurseForge 업로드` 단계 로그에 `HTTP 200`이 찍혀 있으면 성공이에요.

## 6. 올린 뒤에 할 일

- 허브 사이트(<https://hyveo.github.io/addons/>)의 버전을 맞춰요. `hyveo.github.io` 저장소의 `tools/build_addons_pages.py`에서 `version`을 고치고 `python3 tools/build_addons_pages.py`를 실행한 뒤 올려요.
- 기능이 바뀌었으면 CurseForge 프로젝트의 Description(소개글)도 고쳐요. 소개글은 자동으로 바뀌지 않아요.

## 문제가 생기면

| 증상 | 원인과 해결 |
|---|---|
| 릴리즈를 만들었는데 zip이 안 붙음 | 태그 형식이 틀렸어요. 릴리즈와 태그를 지우고 올바른 이름으로 다시 만들어요. |
| 릴리즈 설명이 비어 있음 | `CHANGELOG.md`에 그 버전 항목이 없어요. 항목을 추가하고 릴리즈 설명은 직접 고쳐요. |
| CurseForge에 파일이 안 올라감 | 저장소 Secrets의 `CF_API_KEY`가 없거나 만료됐어요. CurseForge에서 API 토큰을 새로 만들어 Settings → Secrets and variables → Actions에 같은 이름으로 다시 넣어요. |
| CurseForge 로그에 "게임 버전을 찾지 못함" | 와우 포에버 버전이 올라가 CurseForge의 게임 버전 이름이 바뀐 거예요. `release.yml`의 `1.60.1`을 새 버전으로 고쳐요. |
| 같은 버전을 다시 올리고 싶음 | 같은 태그로는 CurseForge에 파일이 하나 더 생겨요. 버전을 올려서 새로 릴리즈하는 편이 깔끔해요. |

## 알아둘 점

- **CurseForge 검수는 별개예요.** 올라간 파일은 "Under Review"로 시작하고, 검수가 끝나야 다른 사람에게 보여요.
- **API 토큰은 비밀번호와 같아요.** 채팅이나 코드에 적지 말고 GitHub Secrets에만 넣어요.
- **커밋 작성자는 `hyveo`로 올려요.** 이 저장소의 커밋은 모두 hyveo 이름으로 남겨요.
