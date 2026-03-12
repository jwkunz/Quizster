#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$ROOT_DIR/server"
SERVER_URL="${SERVER_URL:-http://localhost:8080}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo is required but was not found in PATH."
  exit 1
fi

open_url() {
  local url="$1"
  if command -v xdg-open >/dev/null 2>&1; then
    nohup xdg-open "$url" >/dev/null 2>&1 &
  elif command -v open >/dev/null 2>&1; then
    nohup open "$url" >/dev/null 2>&1 &
  elif command -v start >/dev/null 2>&1; then
    nohup start "$url" >/dev/null 2>&1 &
  else
    echo "No URL opener found (xdg-open/open/start)."
    echo "Open these manually:"
    echo "  $SERVER_URL/admin"
    echo "  $SERVER_URL/player"
    echo "  $SERVER_URL/player"
  fi
}

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    echo "Stopping server (PID $SERVER_PID)..."
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

echo "Starting Quiztik server on ${HOST}:${PORT}..."
(
  cd "$ROOT_DIR"
  QUIZTIK_HOST="$HOST" QUIZTIK_PORT="$PORT" cargo run --release --manifest-path "$SERVER_DIR/Cargo.toml"
) &
SERVER_PID=$!

# Wait for health endpoint
for _ in {1..60}; do
  if curl -fsS "$SERVER_URL/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

if ! curl -fsS "$SERVER_URL/health" >/dev/null 2>&1; then
  echo "Server did not become ready at $SERVER_URL/health"
  exit 1
fi

echo "Server is ready. Launching browser pages..."
open_url "$SERVER_URL/admin"
open_url "$SERVER_URL/player"
open_url "$SERVER_URL/player"

echo "Launched:"
echo "  Admin:   $SERVER_URL/admin"
echo "  Player1: $SERVER_URL/player"
echo "  Player2: $SERVER_URL/player"
echo "Press Ctrl+C to stop the server."

wait "$SERVER_PID"
