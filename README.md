# WoW Forever 애드온 모음

[![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

World of Warcraft: Forever(와우 포에버)에서 쓰는 애드온 모음입니다.
애드온 하나가 `addons/` 아래 폴더 하나이고, 버전과 배포는 애드온별로 따로 관리합니다.

## 애드온 목록

| 애드온 | 설명 | 최신 버전 |
|---|---|---|
| [중앙버튼 (CentarBar)](addons/CentarBar) | 화면 가운데에 액션 버튼 12개를 배치 | [Releases](../../releases) |

## 애드온 요청 받습니다

와우 포에버를 하면서 "이런 애드온 있었으면 좋겠다" 싶은 게 있으면 알려 주세요.
포에버 클라이언트에서 안 돌아가는 기존 애드온을 고쳐 달라는 요청도 좋습니다.

요청은 [Projects](https://github.com/hyveo/wow-forever-addons/projects) 보드에 남겨 주세요.
보드에 직접 쓸 수 없으면 [Issues](../../issues/new?template=addon-request.md)에 올려 주시면 보드로 옮겨 관리합니다.

남겨 주실 내용:

- **원하는 기능**: 어떤 상황에서 무엇을 해 주면 좋은지
- **참고 애드온**: 비슷한 기존 애드온이 있다면 이름과 링크
- **안 될 때 화면**: 기존 애드온 수정 요청이면 오류 메시지나 스크린샷

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

## 후원

애드온이 도움이 됐다면 [GitHub Sponsors](https://github.com/sponsors/hyveo)로 후원해 주세요.
후원은 새 애드온 제작과 포에버 패치 대응에 쓰입니다.

[![Sponsor](https://img.shields.io/badge/Sponsor-hyveo-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/hyveo)

## 저작권

각 애드온의 원작자 표기는 애드온별 README를 따릅니다. 수정 부분: @hyveo
