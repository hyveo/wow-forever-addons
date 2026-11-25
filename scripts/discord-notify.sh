#!/usr/bin/env bash
# 배포 알림을 디스코드 채널로 보낸다.
# 사용법: scripts/discord-notify.sh <애드온폴더명> <버전> <beta|release|promoted>
#   beta      베타로 배포됨
#   release   정식으로 배포됨
#   promoted  베타였던 버전이 정식으로 바뀜
# 웹훅 주소는 저장소 Secrets에서 환경 변수로 받는다 (코드에 적지 않는다):
#   DISCORD_WEBHOOK_CENTERBAR, DISCORD_WEBHOOK_LEVELPACE, DISCORD_WEBHOOK_HYVEOCENTER
# DRY_RUN=1 이면 보내지 않고 보낼 내용만 출력한다.
set -euo pipefail
A="${1:?애드온 이름}"; V="${2:?버전}"; KIND="${3:?beta|release|promoted}"
REPO="${GITHUB_REPOSITORY:-hyveo/wow-forever-addons}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"

case "$A" in
  CenterBar)   HOOK="${DISCORD_WEBHOOK_CENTERBAR:-}";   NAME="센터바 (CenterBar)";            SLUG="centerbar" ;;
  LevelPace)   HOOK="${DISCORD_WEBHOOK_LEVELPACE:-}";   NAME="레벨페이스 (LevelPace)";        SLUG="levelpace" ;;
  HyveoCenter) HOOK="${DISCORD_WEBHOOK_HYVEOCENTER:-}"; NAME="hyveo 애드온 센터 (HyveoCenter)"; SLUG="hyveo-addon-center-hyveo" ;;
  *) echo "알림을 보낼 곳을 모르는 애드온: $A"; exit 0 ;;
esac
TAG="$A-v$V"
CF_URL="https://www.curseforge.com/wow/addons/$SLUG"
GH_URL="https://github.com/$REPO/releases/tag/$TAG"

# 변경 내역: CHANGELOG에서 이 버전 항목만
NOTES=$(awk -v v="$V" '$0 ~ "^## "v"([^0-9.]|$)" {f=1; next} f && /^## / {exit} f' "addons/$A/CHANGELOG.md" | awk 'NF {p=1} p' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')
[ -n "$NOTES" ] || NOTES="(변경 내역 없음)"

# 자세한 설명과 확인할 것: addons/<애드온>/notes/<버전>.md (없으면 그 칸은 빼고 보낸다)
#   ## 자세한 수정 내용   무엇이 문제였고, 왜 그랬고, 어떻게 고쳤는지
#   ## 확인해 볼 것       게임에서 직접 해 볼 항목
NOTE_FILE="addons/$A/notes/$V.md"
section() { # $1 = 제목에 들어 있는 말
  [ -f "$NOTE_FILE" ] || return 0
  awk -v k="$1" '/^## / {f = (index($0, k) > 0); next} f' "$NOTE_FILE" | awk 'NF {p=1} p' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
}
[ -f "$NOTE_FILE" ] || echo "::warning::$NOTE_FILE 이 없어 디스코드 알림에 자세한 수정 내용과 확인할 것이 빠집니다."
DETAIL=$(section "자세한")
CHECKS=$(section "확인" | sed -E 's/^- (\[ \] )?/☐ /')

# 이 버전에 반영된 이슈: 바로 앞 버전 태그 이후 커밋 메시지의 "Refs/Fixes/Closes #번호"
PREV=$(git tag --list "$A-v*" | sort -V | awk -v t="$TAG" '$0==t {print p; exit} {p=$0}')
END_REF="$TAG"; git rev-parse -q --verify "refs/tags/$TAG" >/dev/null || END_REF="HEAD"
RANGE="$END_REF"; [ -n "$PREV" ] && RANGE="$PREV..$END_REF"
NUMS=$(git log --format=%B "$RANGE" -- "addons/$A" 2>/dev/null \
  | grep -iE '(refs|fix(es|ed)?|close[sd]?|resolve[sd]?)[: ]+#[0-9]' \
  | sed -E 's/\(#[0-9]+\)//g' | grep -oE '#[0-9]+' | tr -d '#' | sort -un || true)
ISSUES=""
for n in $NUMS; do
  J=$(gh api "repos/$REPO/issues/$n" 2>/dev/null || true)
  [ -n "$J" ] || continue
  [ "$(echo "$J" | jq -r 'has("pull_request")')" = "true" ] && continue
  T=$(echo "$J" | jq -r '.title')
  K=$(echo "$J" | jq -r '[.labels[].name] | if index("bug") then "버그" elif index("enhancement") then "요청" else "기타" end')
  S=$(echo "$J" | jq -r 'if .state=="closed" then "닫힘" else "확인 중" end')
  ISSUES="${ISSUES}• [#$n](https://github.com/$REPO/issues/$n) $T · $K · $S"$'\n'
done
[ -n "$ISSUES" ] || ISSUES="연결된 이슈 없음"

case "$KIND" in
  beta)
    TITLE="$NAME $V 베타 배포"; COLOR=10181046
    LEAD="**$V** 버전을 베타로 배포했어요. 게임에서 확인이 끝나면 정식으로 바꿔요."
    KINDTEXT="베타 · CurseForge 앱에서 Release Type을 Beta로 바꾼 사람만 받아요" ;;
  release)
    TITLE="$NAME $V 정식 배포"; COLOR=3066993
    LEAD="**$V** 버전을 정식으로 배포했어요. CurseForge 앱에서 업데이트로 받을 수 있어요."
    KINDTEXT="정식 (Release) · 모든 사용자가 받아요" ;;
  promoted)
    TITLE="$NAME $V 정식 릴리즈 (베타 → 정식)"; COLOR=3066993
    LEAD="베타였던 **$V** 버전이 CurseForge에 정식(Release)으로 릴리즈됐어요. 이제 모든 사용자가 업데이트로 받아요."
    KINDTEXT="정식 (Release) · 베타에서 전환" ;;
  *) echo "알 수 없는 종류: $KIND"; exit 1 ;;
esac

# 디스코드 글자 수 제한에 맞춘다 (설명 4096자, 칸 1024자, 알림 하나 전체 6000자)
DESC=$(printf '%s\n\n%s' "$LEAD" "$NOTES" | cut -c1-1800)
DETAIL=$(printf '%s' "$DETAIL" | cut -c1-2400)
CHECKS=$(printf '%s' "$CHECKS" | cut -c1-1200)
ISSUES=$(printf '%s' "$ISSUES" | cut -c1-600)
PAYLOAD=$(jq -n --arg title "$TITLE" --arg desc "$DESC" --arg kind "$KINDTEXT" --arg issues "$ISSUES" \
  --arg detail "$DETAIL" --arg checks "$CHECKS" \
  --arg links "[CurseForge]($CF_URL) · [GitHub 릴리즈]($GH_URL)" --arg url "$GH_URL" --argjson color "$COLOR" \
  '{username:"hyveo addons", allowed_mentions:{parse:[]},
    embeds:(
      [{title:$title, url:$url, description:$desc, color:$color,
        fields:[{name:"배포 종류", value:$kind}, {name:"반영된 이슈·요청", value:$issues}]}]
      + (if $detail != "" then [{title:"자세한 수정 내용", description:$detail, color:$color}] else [] end)
      + (if $checks != "" then [{title:"확인해 볼 것", description:$checks, color:$color}] else [] end)
      + [{color:$color, fields:[{name:"받는 곳", value:$links}]}]
    )}')

if [ "${DRY_RUN:-}" = "1" ]; then echo "$PAYLOAD"; exit 0; fi
if [ -z "$HOOK" ]; then echo "::warning::$A 디스코드 웹훅 Secret이 없어 알림을 건너뜀"; exit 0; fi
CODE=$(curl -sS -o /tmp/discord.out -w '%{http_code}' -H 'Content-Type: application/json' --data "$PAYLOAD" "$HOOK")
echo "디스코드 응답: HTTP $CODE"
case "$CODE" in 2*) ;; *) cat /tmp/discord.out; exit 1 ;; esac
