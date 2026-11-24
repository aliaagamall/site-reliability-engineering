#!/usr/bin/env bash
# Deploys kube-state-metrics and the kubelet (cAdvisor) scrape, checks the
# metrics in Prometheus, and writes a Markdown report.
# Requires: tests/prometheus-test.sh already passed (Prometheus and shop-api running).
#
# Usage:    module-04-sre-operating-model/tests/kubernetes-metrics-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="$(cd "$SCRIPT_DIR/../monitoring/kubernetes-metrics" && pwd)"
CLUSTER="cloudnova-sre"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n monitoring"
PROM="http://127.0.0.1:30900"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/kubernetes-metrics-test.md}"
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

prom_first() {
  curl -s --max-time 10 --get --data-urlencode "query=$1" "$PROM/api/v1/query" \
    | python3 -c 'import json, sys
try:
    r = json.load(sys.stdin)["data"]["result"]
    print(r[0]["value"][1] if r else "none")
except Exception:
    print("none")'
}

# Waits up to 90 s for a query to return a value; prints it ("none" on timeout).
wait_query() {
  local v="none"
  for _ in $(seq 1 45); do
    v="$(prom_first "$1")"
    [ "$v" != "none" ] && break
    sleep 2
  done
  echo "$v"
}

present() { [ "$(wait_query "$1")" != "none" ] && echo yes || echo no; }

# Preconditions 
if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$PROM/-/ready")" != "200" ]; then
  echo "Prometheus is not reachable on $PROM. Run tests/prometheus-test.sh first."
  exit 1
fi

# Deploy 
applied="no"
$KC apply -f "$MANIFESTS" >/tmp/kubernetes-metrics-apply.out 2>&1 && applied="yes"
check "Manifests apply without errors" yes "$applied"
if [ "$applied" != "yes" ]; then
  cat /tmp/kubernetes-metrics-apply.out
  exit 1
fi

rolled="no"
$K rollout status deployment/kube-state-metrics --timeout=180s >/dev/null 2>&1 && rolled="yes"
check "kube-state-metrics deployment rolls out" yes "$rolled"
if [ "$rolled" != "yes" ]; then
  $K get pods
  $K describe pod -l app.kubernetes.io/name=kube-state-metrics | tail -20
  exit 1
fi

svc="no"
for _ in $(seq 1 15); do
  $KC -n kube-system get service kubelet >/dev/null 2>&1 && { svc="yes"; break; }
  sleep 2
done
check "Operator created the kubelet Service in kube-system" yes "$svc"
if [ "$svc" != "yes" ]; then
  echo "The operator was not started with --kubelet-service=kube-system/kubelet."
  echo "Add that argument to the operator Deployment (kustomize patch) and run again."
fi

# Metrics in Prometheus 
check "Target kube-state-metrics is up" 1 "$(wait_query 'up{job="kube-state-metrics"}')"
check "kube-state-metrics keeps the namespace label (shop-api has 1 ready replica)" 1 \
  "$(wait_query 'kube_deployment_status_replicas_ready{namespace="shop",deployment="shop-api"}')"
check "Container restart counts for shop-api are queryable" yes \
  "$(present 'sum(kube_pod_container_status_restarts_total{namespace="shop",container="shop-api"})')"
check "Kubelet cAdvisor target is up" 1 \
  "$(wait_query 'count(up{job="kubelet"} == 1)')"
check "cAdvisor memory for shop-api is queryable" yes \
  "$(present 'container_memory_working_set_bytes{namespace="shop",container="shop-api"}')"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Kubernetes Metrics Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **kube-state-metrics image:** \`$($K get deployment kube-state-metrics -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)\`
- **Manifests:** \`monitoring/kubernetes-metrics/\`
- **Command:** \`tests/kubernetes-metrics-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

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
