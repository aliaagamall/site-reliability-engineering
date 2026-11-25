#!/usr/bin/env bash
# Deploys Prometheus, checks that it scrapes shop-api, and writes a Markdown report.
# Requires: cluster/create.sh, the Prometheus Operator, and shop-api deployed
# (run tests/operator-test.sh and tests/k8s-test.sh first).
#
# Usage:    module-04-sre-operating-model/tests/prometheus-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="$(cd "$SCRIPT_DIR/../monitoring/prometheus" && pwd)"
CLUSTER="cloudnova-sre"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n monitoring"
PROM="http://127.0.0.1:30900"
APP="http://127.0.0.1:30080"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/tests/prometheus-test.md}"
RESULTS=()
FAILED=0

check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

# First value of an instant query, or "none".
prom_first() {
  curl -s --max-time 10 --get --data-urlencode "query=$1" "$PROM/api/v1/query" \
    | python3 -c 'import json, sys
try:
    r = json.load(sys.stdin)["data"]["result"]
    print(r[0]["value"][1] if r else "none")
except Exception:
    print("none")'
}

# Waits up to 60 s for a query to return a value; prints it ("none" on timeout).
wait_query() {
  local v="none"
  for _ in $(seq 1 30); do
    v="$(prom_first "$1")"
    [ "$v" != "none" ] && break
    sleep 2
  done
  echo "$v"
}

# Preconditions 
if ! $KC get crd prometheuses.monitoring.coreos.com >/dev/null 2>&1; then
  echo "Prometheus Operator not found. Run tests/operator-test.sh first."
  exit 1
fi
if ! $KC -n shop get deployment shop-api >/dev/null 2>&1; then
  echo "shop-api is not deployed. Run tests/k8s-test.sh first."
  exit 1
fi

# Deploy 
applied="no"
$KC apply -f "$MANIFESTS" >/tmp/prometheus-apply.out 2>&1 && applied="yes"
check "Manifests apply without errors" yes "$applied"
if [ "$applied" != "yes" ]; then
  cat /tmp/prometheus-apply.out
  exit 1
fi

echo "Waiting for Prometheus (the first start pulls the image)..."
for _ in $(seq 1 60); do
  $K get pod prometheus-main-0 >/dev/null 2>&1 && break
  sleep 2
done
ready="no"
$K wait --for=condition=Ready pod/prometheus-main-0 --timeout=240s >/dev/null 2>&1 && ready="yes"
check "Prometheus pod becomes Ready" yes "$ready"
if [ "$ready" != "yes" ]; then
  $K get pods
  $K describe pod prometheus-main-0 | tail -20
  exit 1
fi

code="000"
for _ in $(seq 1 30); do
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$PROM/-/ready")"
  [ "$code" = "200" ] && break
  sleep 1
done
check "Prometheus responds through node port 30900" 200 "$code"

# Scraping shop-api 
up="$(wait_query 'up{job="shop-api"}')"
check "Target shop-api is up" 1 "$up"

for _ in $(seq 1 10); do
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{"item":"book"}' "$APP/checkout"
done
echo "Sent 10 checkout requests; waiting for the next scrape..."

ok="no"
for _ in $(seq 1 30); do
  v="$(prom_first 'sum(http_requests_total{job="shop-api",endpoint="/checkout",status="200"})')"
  if [ "$v" != "none" ] && awk -v v="$v" 'BEGIN { exit !(v >= 10) }'; then ok="yes"; break; fi
  sleep 2
done
check "http_requests_total{endpoint=\"/checkout\",status=\"200\"} is queryable and counts the requests" yes "$ok"

bucket="$(prom_first 'count(http_request_duration_seconds_bucket{job="shop-api",endpoint="/checkout",le="0.3"})')"
check "The le=\"0.3\" latency bucket is queryable" 1 "$bucket"

exported="$(prom_first 'count({__name__=~"http_.+",exported_endpoint!=""})')"
check "No metrics were relabeled to exported_endpoint" none "$exported"

IMAGE="$($K get pod prometheus-main-0 -o jsonpath='{.spec.containers[?(@.name=="prometheus")].image}' 2>/dev/null)"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Prometheus Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **Prometheus image:** \`$IMAGE\`
- **Manifests:** \`monitoring/prometheus/\`
- **Command:** \`tests/prometheus-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

Prometheus has no persistent volume, so its data is lost if the pod restarts.

## Pods in the monitoring namespace

$FENCE
$($K get pods 2>&1)
$FENCE

## Host memory

$FENCE
$(free -h)
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
