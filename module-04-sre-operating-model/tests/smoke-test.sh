#!/usr/bin/env bash
# Smoke test for shop-api.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/../app" && pwd)"
VENV="$APP_DIR/.venv"
PORT="${PORT:-8080}"
PORT_NOADMIN="${PORT_NOADMIN:-8081}"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/tests/app-smoke-test.md}"
BASE="http://127.0.0.1:$PORT"
BASE_NOADMIN="http://127.0.0.1:$PORT_NOADMIN"
JSON='Content-Type: application/json'
ITEM='{"item":"book"}'

PIDS=()
RESULTS=()
FAILED=0
LOG_DIR="$(mktemp -d)"

# Stop any app still running, whatever way the script exits.
stop_apps() {
  local pid
  for pid in ${PIDS[@]+"${PIDS[@]}"}; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
    fi
  done
  rm -rf "$LOG_DIR"
}
trap stop_apps EXIT

# code METHOD URL [BODY]  ->  prints the HTTP status (000 if unreachable)
code() {
  if [ $# -ge 3 ]; then
    curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" -H "$JSON" -d "$3" "$2"
  else
    curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" -H "$JSON" "$2"
  fi
}

# check NAME EXPECTED ACTUAL  ->  records one result row
check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

# start_app PORT ADMIN_ENABLED
start_app() {
  local port="$1" admin="$2" i
  ADMIN_ENABLED="$admin" "$VENV/bin/gunicorn" -w 1 --threads 8 \
    -b "127.0.0.1:$port" --chdir "$APP_DIR" app:app >"$LOG_DIR/app-$port.log" 2>&1 &
  PIDS+=("$!")
  for i in $(seq 1 40); do
    [ "$(code GET "http://127.0.0.1:$port/health")" = "200" ] && return 0
    sleep 0.5
  done
  echo "App did not start on port $port:"
  cat "$LOG_DIR/app-$port.log"
  return 1
}

# Setup 
if [ ! -x "$VENV/bin/gunicorn" ]; then
  echo "Creating virtual environment..."
  python3 -m venv "$VENV" && "$VENV/bin/pip" install -q -r "$APP_DIR/requirements.txt" || {
    echo "Could not set up the virtual environment."
    exit 1
  }
fi

for p in "$PORT" "$PORT_NOADMIN"; do
  if [ "$(code GET "http://127.0.0.1:$p/health")" != "000" ]; then
    echo "Port $p is already in use. Stop the process using it and run again."
    exit 1
  fi
done

# Tests: app with admin endpoints enabled 
echo "Starting shop-api on port $PORT..."
start_app "$PORT" true || exit 1

check "GET /health returns 200" 200 "$(code GET "$BASE/health")"
check "POST /checkout with valid body returns 200" 200 "$(code POST "$BASE/checkout" "$ITEM")"
check "POST /checkout with invalid body returns 400" 400 "$(code POST "$BASE/checkout" 'bad')"
check "POST /admin/faults with error_rate=2 returns 400" 400 "$(code POST "$BASE/admin/faults" '{"error_rate":2}')"
check "POST /admin/faults with unknown fault returns 400" 400 "$(code POST "$BASE/admin/faults" '{"unknown":1}')"

curl -s -o /dev/null -X POST -H "$JSON" -d '{"db_down":true}' "$BASE/admin/faults"
check "db_down: POST /checkout returns 503" 503 "$(code POST "$BASE/checkout" "$ITEM")"
check "db_down: GET /health still returns 200" 200 "$(code GET "$BASE/health")"
check "db_down: GET /metrics still returns 200" 200 "$(code GET "$BASE/metrics")"

curl -s -o /dev/null -X POST -H "$JSON" -d '{"db_down":false,"error_rate":1.0}' "$BASE/admin/faults"
check "error_rate=1.0: POST /checkout returns 500" 500 "$(code POST "$BASE/checkout" "$ITEM")"

curl -s -o /dev/null -X POST -H "$JSON" -d '{"error_rate":0,"latency_ms":500}' "$BASE/admin/faults"
out="$(curl -s -o /dev/null -w '%{http_code} %{time_total}' -X POST -H "$JSON" -d "$ITEM" "$BASE/checkout")"
check "latency_ms=500: POST /checkout returns 200" 200 "${out% *}"
slow="$(awk -v t="${out#* }" 'BEGIN { print (t >= 0.5) ? "yes" : "no" }')"
check "latency_ms=500: request takes at least 0.5 s" yes "$slow"

curl -s -o /dev/null -X POST -H "$JSON" -d '{"latency_ms":0}' "$BASE/admin/faults"
check "After faults reset: POST /checkout returns 200" 200 "$(code POST "$BASE/checkout" "$ITEM")"

metrics="$(curl -s "$BASE/metrics")"
has() { grep -qF -- "$1" <<<"$metrics" && echo yes || echo no; }
for s in 200 400 500 503; do
  check "Metrics contain /checkout status $s" yes \
    "$(has "http_requests_total{endpoint=\"/checkout\",status=\"$s\"}")"
done
check "Metrics contain the 0.3 s latency bucket" yes \
  "$(has 'http_request_duration_seconds_bucket{endpoint="/checkout",le="0.3"}')"
check "Metrics do not count /health requests" no "$(has 'endpoint="/health"')"

sample="$(grep -E '^http_requests_total\{|^http_request_duration_seconds_(bucket\{endpoint="/checkout",le="(0\.3|\+Inf)"|count\{)' <<<"$metrics")"

# Tests: admin endpoints disabled by default
echo "Starting shop-api without ADMIN_ENABLED on port $PORT_NOADMIN..."
start_app "$PORT_NOADMIN" false || exit 1
check "Admin disabled: GET /admin/faults returns 404" 404 "$(code GET "$BASE_NOADMIN/admin/faults")"
check "Admin disabled: POST /admin/crash returns 404" 404 "$(code POST "$BASE_NOADMIN/admin/crash")"
check "Admin disabled: app keeps running" 200 "$(code GET "$BASE_NOADMIN/health")"

# Test: crash 
check "POST /admin/crash returns 202" 202 "$(code POST "$BASE/admin/crash")"
stopped="no"
for _ in $(seq 1 20); do
  sleep 0.5
  if [ "$(code GET "$BASE/health")" = "000" ]; then
    stopped="yes"
    break
  fi
done
check "Process stops after the crash request" yes "$stopped"

# Report 
TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# shop-api Smoke Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Python:** $("$VENV/bin/python" --version 2>&1)
- **Gunicorn:** $("$VENV/bin/gunicorn" --version 2>&1)
- **Environment:** local run with Gunicorn (one worker, 8 threads), not yet in Docker or Kubernetes
- **Command:** \`tests/smoke-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

## Metrics sample

Taken from \`/metrics\` after the fault tests (before the crash test).

$FENCE
$sample
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
