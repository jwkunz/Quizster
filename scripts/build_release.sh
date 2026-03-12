#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-$(cat VERSION)}"
VERSION="${VERSION#v}"
TARGET="${2:-local}"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DIR="$DIST_DIR/stage"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR" "$STAGE_DIR/server" "$STAGE_DIR/player" "$STAGE_DIR/admin"

if [[ -f server/target/release/quiztik-server ]]; then
  cp server/target/release/quiztik-server "$STAGE_DIR/server/quiztik-server"
else
  cat > "$STAGE_DIR/server/README.txt" <<TXT
No server binary present for target '$TARGET'.
Build server first, then rerun this script.
TXT
fi

if [[ -f web/player/player.html ]]; then
  cp web/player/player.html "$STAGE_DIR/player/player.html"
else
  echo "Missing player.html" > "$STAGE_DIR/player/README.txt"
fi

if [[ -f web/admin/admin.html ]]; then
  cp web/admin/admin.html "$STAGE_DIR/admin/admin.html"
else
  echo "Missing admin.html" > "$STAGE_DIR/admin/README.txt"
fi

(cd "$STAGE_DIR/server" && zip -qr "$DIST_DIR/quiztik-server-${TARGET}-v${VERSION}.zip" .)
(cd "$STAGE_DIR/player" && zip -qr "$DIST_DIR/quiztik-player-v${VERSION}.zip" .)
(cd "$STAGE_DIR/admin" && zip -qr "$DIST_DIR/quiztik-admin-v${VERSION}.zip" .)

rm -rf "$STAGE_DIR"
ls -1 "$DIST_DIR"
