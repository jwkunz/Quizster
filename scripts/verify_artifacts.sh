#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-$(cat VERSION)}"
VERSION="${VERSION#v}"
TARGET="${2:-local}"

SERVER_ZIP="dist/quiztik-server-${TARGET}-v${VERSION}.zip"

for f in "$SERVER_ZIP"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing artifact: $f"
    exit 1
  fi
done

if ! unzip -l "$SERVER_ZIP" | rg -q "quiztik-server|quiztik-server.exe|README.txt"; then
  echo "server executable/readme missing from server zip"
  exit 1
fi

if ! unzip -l "$SERVER_ZIP" | rg -q "web/player/player.html"; then
  echo "player html missing from server zip"
  exit 1
fi

if ! unzip -l "$SERVER_ZIP" | rg -q "web/admin/admin.html"; then
  echo "admin html missing from server zip"
  exit 1
fi

if ! unzip -l "$SERVER_ZIP" | rg -q "assets/questions/"; then
  echo "question banks missing from server zip"
  exit 1
fi

echo "Artifacts verified for v${VERSION} target=${TARGET}"
