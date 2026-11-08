#!/usr/bin/env bash
# 사용법: scripts/package.sh <애드온폴더명> <버전>
#   예: scripts/package.sh CentarBar 1.62  →  dist/CentarBar-1.62.zip
# addons/<애드온>/ 아래에서 .toc가 있는 폴더(게임에 들어가는 폴더)만 zip에 담고,
# TOC의 @project-version@ 을 버전으로 바꾼다.
set -euo pipefail
ADDON="${1:?애드온 이름이 필요합니다 (예: CentarBar)}"
VERSION="${2:?버전이 필요합니다 (예: 1.62)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/addons/$ADDON"
[ -d "$SRC" ] || { echo "addons/$ADDON 폴더가 없습니다" >&2; exit 1; }

STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
found=0
for dir in "$SRC"/*/; do
  name="$(basename "$dir")"
  ls "$dir"*.toc >/dev/null 2>&1 || continue
  cp -R "$dir" "$STAGE/$name"
  find "$STAGE/$name" -name '*.toc' -exec sed -i.bak "s/@project-version@/$VERSION/g" {} \; -exec rm -f {}.bak \;
  found=1
done
[ "$found" = 1 ] || { echo "addons/$ADDON 안에 .toc가 있는 폴더가 없습니다" >&2; exit 1; }

mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/$ADDON-$VERSION.zip"
rm -f "$OUT"
(cd "$STAGE" && zip -qr "$OUT" .)
echo "$OUT"
