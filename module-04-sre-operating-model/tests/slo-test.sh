#!/usr/bin/env bash
# Applies the shop-api SLOs, checks that Pyrra generated rules and that
# Prometheus loaded them, then injects a database failure and checks that the
# availability burn rate rises. Writes a Markdown report.
# Requires: Pyrra (tests/pyrra-test.sh) and shop-api (tests/k8s-test.sh).
# Takes about 3 to 6 minutes.
#
# Usage:    module-04-sre-operating-model/tests/slo-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLO_DIR="$(cd "$SCRIPT_DIR/../monitoring/slos" && pwd)"
LOADGEN="$SCRIPT_DIR/../loadgen/loadgen.py"
CLUSTER="cloudnova-sre"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n monitoring"
PROM="http://127.0.0.1:30900"
APP="http://127.0.0.1:30080"
AVAIL="shop-api-availability"
LAT="shop-api-latency"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/tests/slo-test.md}"
WORK="$(mktemp -d)"
RESULTS=()
FAILED=0
LG_PID=""

reset_faults() {
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' \
    -d '{"db_down":false,"error_rate":0,"latency_ms":0}' "$APP/admin/faults"
}
cleanup() {
  if [ -n "$LG_PID" ]; then kill "$LG_PID" 2>/dev/null; wait "$LG_PID" 2>/dev/null; fi
  reset_faults
  rm -rf "$WORK"
}
trap cleanup EXIT

check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

prom_first() {
  curl -s --max-time 10 --get --data-urlencode "query=$1" "$PROM/api/v1/query" \
    | python3 -c 'import json, sys
try:
    r = json.load(sys.stdin)["data"]["result"]
    print(r[0]["value"][1] if r else "none")
except Exception:
    print("none")'
}

# Number of rule groups (or alerting rules) whose group name starts with an SLO name.
rules_count() {  # $1 = SLO name, $2 = groups | alerts
  curl -s --max-time 10 "$PROM/api/v1/rules" | python3 -c '
import json, sys
slo, what = sys.argv[1], sys.argv[2]
try:
    groups = [g for g in json.load(sys.stdin)["data"]["groups"] if g["name"].startswith(slo)]
except Exception:
    groups = []
if what == "groups":
    print(len(groups))
else:
    print(sum(1 for g in groups for r in g["rules"] if r["type"] == "alerting"))
' "$1" "$2"
}

# Name of the 5 minute burn rate recording rule of an SLO.
burn_record() {
  curl -s --max-time 10 "$PROM/api/v1/rules" | python3 -c '
import json, sys
slo = sys.argv[1]
try:
    for g in json.load(sys.stdin)["data"]["groups"]:
        if g["name"].startswith(slo):
            for r in g["rules"]:
                if r["type"] == "recording" and r["name"].endswith("burnrate5m"):
                    print(r["name"]); sys.exit()
except Exception:
    pass
print("none")
' "$1"
}

# Succeeds and prints the value when the command prints a non-zero, non-"none" value.
wait_until() {  # $1 = max tries (2 s each), rest = command
  local tries="$1" v; shift
  for _ in $(seq 1 "$tries"); do
    v="$("$@")"
    if [ -n "$v" ] && [ "$v" != "0" ] && [ "$v" != "none" ]; then echo "$v"; return 0; fi
    sleep 2
  done
  echo "none"; return 1
}
yesno() { [ "$1" = "none" ] && echo no || echo yes; }

# --- Preconditions -------------------------------------------------------
if ! $K get deployment pyrra-kubernetes >/dev/null 2>&1; then
  echo "Pyrra is not installed. Run tests/pyrra-test.sh first."; exit 1
fi
if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$PROM/-/ready")" != "200" ]; then
  echo "Prometheus is not reachable. Run tests/prometheus-test.sh first."; exit 1
fi
if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$APP/health")" != "200" ]; then
  echo "shop-api is not reachable on $APP. Run tests/k8s-test.sh first."; exit 1
fi
reset_faults

# Apply and check generated rules 
applied="no"
$KC apply -f "$SLO_DIR" >"$WORK/apply.out" 2>&1 && applied="yes"
check "SLO manifests apply without errors" yes "$applied"
if [ "$applied" != "yes" ]; then cat "$WORK/apply.out"; exit 1; fi

check "Both SLO resources exist" 2 "$($K get servicelevelobjectives.pyrra.dev --no-headers 2>/dev/null | grep -c 'shop-api')"

echo "Waiting for Pyrra to generate rules and Prometheus to load them..."
for slo in "$AVAIL" "$LAT"; do
  found="none"
  for _ in $(seq 1 30); do
    $K get prometheusrule "$slo" >/dev/null 2>&1 && { found="yes"; break; }
    sleep 2
  done
  check "PrometheusRule '$slo' was generated" yes "$(yesno "$found")"
done
for slo in "$AVAIL" "$LAT"; do
  g="$(wait_until 60 rules_count "$slo" groups)"
  check "Prometheus loaded the rule groups of '$slo'" yes "$(yesno "$g")"
done
for slo in "$AVAIL" "$LAT"; do
  n="$(rules_count "$slo" alerts)"
  has_alerts="no"
  [ "${n:-0}" -gt 0 ] 2>/dev/null && has_alerts="yes"
  check "Alerting rules exist for '$slo'" yes "$has_alerts"
done

# Severity labels per burn-rate tier, identified by the rule's "for" duration (seconds).
cat >"$WORK/tiers.py" << 'PY_EOF'
import json, sys
slo, kind = sys.argv[1], sys.argv[2]
group = slo + ("-increase" if kind == "absent" else "")
items = []
try:
    for g in json.load(sys.stdin)["data"]["groups"]:
        if g["name"] == group:
            for r in g["rules"]:
                if r["type"] == "alerting":
                    items.append((int(r.get("duration", 0)), r["labels"].get("severity", "")))
except Exception:
    pass
if kind == "absent":
    print(",".join(sorted({s for _, s in items})) or "none")
else:
    print(",".join("{}={}".format(d, s) for d, s in sorted(items)) or "none")
PY_EOF
# Prometheus reloads the regenerated rules after a short delay, so wait for the expected value.
wait_tiers() {  # $1 = SLO, $2 = burn | absent, $3 = expected value
  local v="none"
  for _ in $(seq 1 60); do
    v="$(curl -s --max-time 10 "$PROM/api/v1/rules" | python3 "$WORK/tiers.py" "$1" "$2")"
    [ "$v" = "$3" ] && break
    sleep 2
  done
  echo "$v"
}
TIERS="120=sev1,900=sev2,3600=sev3,10800=sev3"
check "Availability alerts: for-duration to severity (2m, 15m, 1h, 3h)" "$TIERS" "$(wait_tiers "$AVAIL" burn "$TIERS")"
check "Latency alerts: for-duration to severity (2m, 15m, 1h, 3h)" "$TIERS" "$(wait_tiers "$LAT" burn "$TIERS")"
check "Metric-absent alerts use severity sev2 (both SLOs)" sev2/sev2 \
  "$(wait_tiers "$AVAIL" absent sev2)/$(wait_tiers "$LAT" absent sev2)"

REC="$(wait_until 30 burn_record "$AVAIL")"
check "Burn rate recording rule (5m) exists for the availability SLO" yes "$(yesno "$REC")"

# Inject a database failure and watch the burn rate 
echo "Sending normal traffic for 20 s..."
python3 "$LOADGEN" --url "$APP" --rate 10 --duration 20 >/dev/null 2>&1

echo "Injecting db_down and sending traffic (up to 3 minutes)..."
curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{"db_down":true}' "$APP/admin/faults"
python3 "$LOADGEN" --url "$APP" --rate 10 --duration 200 >/dev/null 2>&1 &
LG_PID=$!

# Pyrra's burnrate recording rules hold the error ratio of the window.
# Burn rate = error ratio / error budget (0.001 for the 99.9% SLO).
ratio="none"
if [ "$REC" != "none" ]; then
  for _ in $(seq 1 90); do
    v="$(prom_first "$REC{slo=\"$AVAIL\"}")"
    if [ "$v" != "none" ] && awk -v v="$v" 'BEGIN { exit !(v > 0.0144) }'; then ratio="$v"; break; fi
    sleep 2
  done
fi
burn="none"
[ "$ratio" != "none" ] && burn="$(awk -v v="$ratio" 'BEGIN { printf "%.1f", v / 0.001 }')"
ok="no"; [ "$burn" != "none" ] && ok="yes"
check "5m burn rate rises above 14.4 during db_down (burn rate: $burn)" yes "$ok"

kill "$LG_PID" 2>/dev/null; wait "$LG_PID" 2>/dev/null; LG_PID=""
reset_faults

# Collect generated alert rules for the report 
cat >"$WORK/rules.py" << 'PY_EOF'
import json, sys
for g in json.load(sys.stdin)["data"]["groups"]:
    if g["name"].startswith("shop-api-"):
        for r in g["rules"]:
            if r["type"] == "alerting":
                print("{} | {} | severity={} | for={}s".format(
                    g["name"], r["name"], r["labels"].get("severity"), r.get("duration", 0)))
                print("    " + r["query"])
PY_EOF
cat >"$WORK/alerts.py" << 'PY_EOF'
import json, sys
for a in json.load(sys.stdin)["data"]["alerts"]:
    l = a["labels"]
    if l.get("slo", "").startswith("shop-api-"):
        print("{} | slo={} | severity={} | state={}".format(
            l["alertname"], l["slo"], l.get("severity"), a["state"]))
PY_EOF
curl -s "$PROM/api/v1/rules" | python3 "$WORK/rules.py" >"$WORK/alerts.txt" 2>&1
curl -s "$PROM/api/v1/alerts" | python3 "$WORK/alerts.py" >"$WORK/alert-states.txt" 2>&1

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# SLO Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **SLO definitions:** \`monitoring/slos/\`
- **Command:** \`tests/slo-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

The test injects \`db_down\` for about 2 minutes, so the error budget of the availability SLO is consumed on purpose. The latency SLO is not exercised here. Prometheus has no persistent volume, so this data is lost if it restarts. Pyrra's \`burnrate\` recording rules hold the error ratio of each window; the alert expressions multiply the threshold by the error budget.

## Alerting rules generated by Pyrra

Group, alert name, severity label, and duration, followed by the expression.

$FENCE
$(cat "$WORK/alerts.txt")
$FENCE

## Alert states at the end of the test

$FENCE
$(cat "$WORK/alert-states.txt")
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
