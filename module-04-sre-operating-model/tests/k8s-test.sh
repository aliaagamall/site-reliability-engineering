#!/usr/bin/env bash
# Deploys shop-api to the kind cluster, tests it, and writes a Markdown report.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/../app" && pwd)"
MANIFESTS="$(cd "$SCRIPT_DIR/../k8s" && pwd)"
CLUSTER="cloudnova-sre"
NODE="$CLUSTER-control-plane"
IMAGE="shop-api:1.0.0"
LOCAL_PORT="${LOCAL_PORT:-18080}"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/k8s-test.md}"
BASE="http://127.0.0.1:$LOCAL_PORT"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n shop"
LABEL="app.kubernetes.io/name=shop-api"
RESULTS=()
FAILED=0
PF_PID=""

cleanup() {
  if [ -n "$PF_PID" ]; then kill "$PF_PID" 2>/dev/null; fi
}
trap cleanup EXIT

code() {
  if [ $# -ge 3 ]; then
    curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" \
      -H 'Content-Type: application/json' -d "$3" "$2"
  else
    curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" "$2"
  fi
}

check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

pod_field() { $K get pod -l "$LABEL" -o jsonpath="{.items[0].$1}" 2>/dev/null; }

# Preconditions
if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' not found. Run cluster/create.sh first."
  exit 1
fi
if [ "$(code GET "$BASE/health")" != "000" ]; then
  echo "Port $LOCAL_PORT is already in use. Stop the process using it and run again."
  exit 1
fi

# Image 
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Building $IMAGE..."
  docker build -q -t "$IMAGE" "$APP_DIR" >/dev/null || { echo "Image build failed."; exit 1; }
fi
echo "Loading $IMAGE into the cluster..."
kind load docker-image "$IMAGE" --name "$CLUSTER" >/dev/null 2>&1
loaded="no"
docker exec "$NODE" crictl images 2>/dev/null | grep -q 'shop-api' && loaded="yes"
check "Image is loaded into the cluster" yes "$loaded"

# Deploy 
applied="no"
$KC apply -f "$MANIFESTS" >/dev/null 2>&1 && applied="yes"
check "Manifests apply without errors" yes "$applied"

rolled="no"
$K rollout status deployment/shop-api --timeout=120s >/dev/null 2>&1 && rolled="yes"
check "Deployment rolls out" yes "$rolled"
if [ "$rolled" != "yes" ]; then
  $K get pods
  $K describe pod -l "$LABEL" | tail -20
  exit 1
fi
check "Deployment has 1 ready replica" 1 "$($K get deployment shop-api -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
check "Container runs as UID 10001" 10001 "$($K exec deploy/shop-api -- id -u 2>/dev/null)"

# Through the Service 
$K port-forward svc/shop-api "$LOCAL_PORT:8080" >/dev/null 2>&1 &
PF_PID=$!
for _ in $(seq 1 20); do
  [ "$(code GET "$BASE/health")" = "200" ] && break
  sleep 0.5
done
check "GET /health through the Service returns 200" 200 "$(code GET "$BASE/health")"
check "POST /checkout through the Service returns 200" 200 "$(code POST "$BASE/checkout" '{"item":"book"}')"
check "GET /metrics through the Service returns 200" 200 "$(code GET "$BASE/metrics")"
check "GET /admin/faults returns 200 (ADMIN_ENABLED=true)" 200 "$(code GET "$BASE/admin/faults")"
kill "$PF_PID" 2>/dev/null
PF_PID=""

# Crash: Kubernetes restarts the container 
before="$(pod_field 'status.containerStatuses[0].restartCount')"
before="${before:-0}"
out="$($K exec deploy/shop-api -- python -c 'import urllib.request as u; print(u.urlopen(u.Request("http://127.0.0.1:8080/admin/crash", method="POST")).status)' 2>/dev/null)"
check "POST /admin/crash returns 202" 202 "$out"

after="$before"
ready="false"
for _ in $(seq 1 60); do
  sleep 1
  after="$(pod_field 'status.containerStatuses[0].restartCount')"
  ready="$(pod_field 'status.containerStatuses[0].ready')"
  if [ "$after" = "$((before + 1))" ] && [ "$ready" = "true" ]; then break; fi
done
check "Kubernetes restarts the container (restart count +1)" "$((before + 1))" "$after"
check "Last container exit code is 3" 3 "$(pod_field 'status.containerStatuses[0].lastState.terminated.exitCode')"
check "Pod is Ready again after the restart" true "$ready"

# Report 
TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Kubernetes Deployment Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **Image:** \`$IMAGE\` (loaded into kind, not pulled from a registry)
- **Manifests:** \`k8s/\`, applied with \`kubectl apply\` (Argo CD takes over this role later)
- **Command:** \`tests/k8s-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

The crash test is a process crash handled by the container restart policy.
It is not a CrashLoopBackOff, which is tested separately later.

## Resources in the shop namespace (after the crash test)

$FENCE
$($K get pods,svc -o wide 2>&1)
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
