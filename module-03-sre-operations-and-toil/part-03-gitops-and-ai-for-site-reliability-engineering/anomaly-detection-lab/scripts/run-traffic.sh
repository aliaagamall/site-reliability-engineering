#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
DURATION="${2:-}"

case "$MODE" in
  normal|spike) ;;
  *) echo "usage: $0 normal|spike [duration_seconds]"; exit 1 ;;
esac

ARGS=()
if [ -n "$DURATION" ]; then
  ARGS=(-e "DURATION=$DURATION")
fi

docker compose run --rm "${ARGS[@]}" traffic python "${MODE}_traffic.py"