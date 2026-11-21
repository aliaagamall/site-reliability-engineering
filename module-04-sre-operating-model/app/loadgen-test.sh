#!/usr/bin/env bash
# Tests loadgen.py against a local shop-api and writes a Markdown report.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"
LOADGEN="$SCRIPT_DIR/loadgen.py"
PORT="${PORT:-8080}"
PORT_DOWN="${PORT_DOWN:-8099}"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/app-loadgen-test.md}"
BASE="http://127.0.0.1:$PORT"
JSON='Content-Type: application/json'

APP_PID=""
RESULTS=()
FAILED=0
LOG_DIR="$(mktemp -d)"

stop_app() {
  if [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID" 2>/dev/null
    wait "$APP_PID" 2>/dev/null
  fi
  rm -rf "$LOG_DIR"
}
trap stop_app EXIT

code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" "$2"; }

check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

# Values from a loadgen summary file.
sent()   { awk '/requests sent:/ {print $3}' "$1"; }
status() { awk -v s="status $2:" '$0 ~ "^  " s {print $3}' "$1"; }
within() { awk '/within 300 ms:/ {gsub("%", "", $4); print $4}' "$1"; }
# Value of http_requests_total for /checkout and a status, from the app.
app_count() {
  local v
  v="$(curl -s "$BASE/metrics" \
    | grep -F "http_requests_total{endpoint=\"/checkout\",status=\"$1\"}" \
    | awk '{print int($2)}')"
  echo "${v:-0}"
}
set_faults() { curl -s -o /dev/null -X POST -H "$JSON" -d "$1" "$BASE/admin/faults"; }

# Setup 
if [ ! -x "$VENV/bin/gunicorn" ]; then
  echo "Creating virtual environment..."
  python3 -m venv "$VENV" && "$VENV/bin/pip" install -q -r "$SCRIPT_DIR/requirements.txt" || {
    echo "Could not set up the virtual environment."
    exit 1
  }
fi
for p in "$PORT" "$PORT_DOWN"; do
  if [ "$(code GET "http://127.0.0.1:$p/health")" != "000" ]; then
    echo "Port $p is already in use. Stop the process using it and run again."
    exit 1
  fi
done

echo "Starting shop-api on port $PORT..."
ADMIN_ENABLED=true "$VENV/bin/gunicorn" -w 1 --threads 8 -b "127.0.0.1:$PORT" \
  --chdir "$SCRIPT_DIR" app:app >"$LOG_DIR/app.log" 2>&1 &
APP_PID=$!
for _ in $(seq 1 40); do
  [ "$(code GET "$BASE/health")" = "200" ] && break
  sleep 0.5
done
if [ "$(code GET "$BASE/health")" != "200" ]; then
  echo "App did not start:"
  cat "$LOG_DIR/app.log"
  exit 1
fi

# Normal traffic: 20 req/s for 5 s 
python3 "$LOADGEN" --url "$BASE" --rate 20 --duration 5 >"$LOG_DIR/normal.out" 2>&1
check "Normal run exits with code 0" 0 "$?"
n_sent="$(sent "$LOG_DIR/normal.out")"
n_sent="${n_sent:-0}"
in_range="no"
[ "$n_sent" -ge 95 ] && [ "$n_sent" -le 105 ] && in_range="yes"
check "Sends about 100 requests (95 to 105)" yes "$in_range"
check "All requests return 200" "$n_sent" "$(status "$LOG_DIR/normal.out" 200)"
ok_pct="$(awk -v p="$(within "$LOG_DIR/normal.out")" 'BEGIN { print (p >= 95) ? "yes" : "no" }')"
check "At least 95% of requests finish within 300 ms" yes "$ok_pct"
check "App metrics count the same 200 responses" "$(status "$LOG_DIR/normal.out" 200)" "$(app_count 200)"

# Failure traffic: error_rate=1.0 
before_500="$(app_count 500)"
set_faults '{"error_rate":1.0}'
python3 "$LOADGEN" --url "$BASE" --rate 10 --duration 2 >"$LOG_DIR/fault.out" 2>&1
set_faults '{"error_rate":0}'
f_sent="$(sent "$LOG_DIR/fault.out")"
f_sent="${f_sent:-0}"
all500="no"
[ "$f_sent" -gt 0 ] && [ "$(status "$LOG_DIR/fault.out" 500)" = "$f_sent" ] && all500="yes"
check "With error_rate=1.0 all requests return 500" yes "$all500"
check "App metrics count the same 500 responses" "$f_sent" "$(( $(app_count 500) - before_500 ))"

# Stops cleanly on SIGINT (no --duration) 
python3 "$LOADGEN" --url "$BASE" --rate 10 >"$LOG_DIR/stop.out" 2>&1 &
lg_pid=$!
sleep 3
kill -INT "$lg_pid"
wait "$lg_pid"
check "Stops cleanly on SIGINT (exit code 0)" 0 "$?"
has_summary="no"
grep -q '^Summary' "$LOG_DIR/stop.out" && has_summary="yes"
check "Prints a summary when stopped" yes "$has_summary"

# Unreachable app 
python3 "$LOADGEN" --url "http://127.0.0.1:$PORT_DOWN" --rate 5 --duration 1 >"$LOG_DIR/down.out" 2>&1
check "Unreachable app: loadgen still exits with code 0" 0 "$?"
d_sent="$(sent "$LOG_DIR/down.out")"
d_sent="${d_sent:-0}"
all_err="no"
[ "$d_sent" -gt 0 ] && [ "$(status "$LOG_DIR/down.out" error)" = "$d_sent" ] && all_err="yes"
check "Unreachable app: every request is counted as error" yes "$all_err"

# Invalid arguments 
python3 "$LOADGEN" --rate 0 >/dev/null 2>&1
check "Invalid --rate 0 is rejected (exit code 2)" 2 "$?"

# Report 
TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Load Generator Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Python:** $(python3 --version 2>&1)
- **Environment:** local run, \`app/loadgen.py\` against \`shop-api\` on Gunicorn
- **Command:** \`app/loadgen-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

## Sample output

Normal traffic: \`loadgen.py --rate 20 --duration 5\`

$FENCE
$(cat "$LOG_DIR/normal.out")
$FENCE

Failure traffic with \`error_rate=1.0\`: \`loadgen.py --rate 10 --duration 2\`

$FENCE
$(cat "$LOG_DIR/fault.out")
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
