#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  normal)   RATE=0.002 ;;  # 0.2% errors -> burn rate ~0.2
  degraded) RATE=0.03  ;;  # 3% errors   -> burn rate ~3  (slow burn only)
  incident) RATE=0.10  ;;  # 10% errors  -> burn rate ~10 (fast + slow burn)
  *) echo "usage: $0 normal|degraded|incident"; exit 1 ;;
esac

curl -fsS -X POST "http://localhost:8000/admin/error-rate/${RATE}"
echo