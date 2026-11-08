# WoW Forever 애드온 모음

World of Warcraft: Forever(와우 포에버)에서 쓰는 애드온 모음입니다.
애드온 하나가 `addons/` 아래 폴더 하나이고, 버전과 배포는 애드온별로 따로 관리합니다.

## 애드온 목록

| 애드온 | 설명 | 최신 버전 |
|---|---|---|
| [중앙버튼 (CentarBar)](addons/CentarBar) | 화면 가운데에 액션 버튼 12개를 배치 | [Releases](../../releases) |

## 설치

1. [Releases](../../releases)에서 원하는 애드온의 zip을 받습니다.
2. 압축을 풀어 나온 폴더를 `World of Warcraft\_forever_\Interface\AddOns\` 에 넣습니다.
   이전 버전이 있으면 해당 폴더를 지우고 새로 넣으세요.
3. 게임을 완전히 재시작합니다 (`/reload`로는 TOC가 다시 읽히지 않습니다).

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

태그 이름은 `<애드온폴더명>-v<버전>` 입니다.

```bash
git tag CentarBar-v1.63
git push origin CentarBar-v1.63
```

GitHub Actions가 해당 애드온만 zip으로 묶고, TOC의 `@project-version@`을 버전으로 바꿔 Release에 올립니다.
로컬에서 zip만 만들려면 `scripts/package.sh CentarBar 1.63` (결과: `dist/`).

## 저작권

각 애드온의 원작자 표기는 애드온별 README를 따릅니다. 수정 부분: @hyveo
