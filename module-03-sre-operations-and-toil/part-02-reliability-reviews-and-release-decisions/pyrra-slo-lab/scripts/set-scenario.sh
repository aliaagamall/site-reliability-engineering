#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  meet)    RATE=0.002 ;;  # 0.2% errors -> ~99.8% availability
  violate) RATE=0.05  ;;  # 5% errors   -> ~95% availability
  *) echo "usage: $0 meet|violate"; exit 1 ;;
esac

curl -fsS -X POST "http://localhost:8000/admin/error-rate/${RATE}"
echo