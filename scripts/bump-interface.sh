#!/usr/bin/env bash
# 사용법: scripts/bump-interface.sh <인터페이스번호>
#   예: scripts/bump-interface.sh 16003
# 게임에서 /dump select(4, GetBuildInfo()) 로 확인한 번호를
# 모든 애드온 TOC의 "## Interface:" 맨 앞에 추가한다 (이미 있으면 건너뜀).
set -euo pipefail
NEW="${1:?인터페이스 번호가 필요합니다 (예: 16003)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
find "$ROOT/addons" -name '*.toc' | while read -r toc; do
  line="$(grep -m1 '^## Interface:' "$toc" || true)"
  [ -n "$line" ] || continue
  if echo "$line" | grep -Eq "(:|,)[[:space:]]*$NEW([[:space:]]*,|[[:space:]]*$)"; then
    echo "건너뜀  ${toc#$ROOT/}"
  else
    sed -i.bak "s/^## Interface:[[:space:]]*/## Interface: $NEW, /" "$toc" && rm -f "$toc.bak"
    echo "추가함  ${toc#$ROOT/}"
  fi
done
