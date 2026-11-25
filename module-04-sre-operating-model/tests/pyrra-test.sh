#!/usr/bin/env bash
# Installs Pyrra in the kind cluster, verifies it, and writes a Markdown report.
# Requires the Prometheus Operator CRDs and Prometheus (run the earlier tests first).
#
# Usage:    module-04-sre-operating-model/tests/pyrra-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYRRA_DIR="$(cd "$SCRIPT_DIR/../monitoring/pyrra" && pwd)"
CLUSTER="cloudnova-sre"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n monitoring"
UI="http://127.0.0.1:30099"
EXPECTED_IMAGE="ghcr.io/pyrra-dev/pyrra:v0.10.2"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/tests/pyrra-test.md}"
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

if ! $KC get crd prometheusrules.monitoring.coreos.com >/dev/null 2>&1; then
  echo "Prometheus Operator CRDs not found. Run tests/operator-test.sh first."
  exit 1
fi
if ! $K get pod prometheus-main-0 >/dev/null 2>&1; then
  echo "Prometheus is not running. Run tests/prometheus-test.sh first."
  exit 1
fi

# Deploy 
crd_applied="no"
$KC apply --server-side -f "$PYRRA_DIR/crds" >/tmp/pyrra-crd-apply.out 2>&1 && crd_applied="yes"
check "CRD applies without errors" yes "$crd_applied"
if [ "$crd_applied" != "yes" ]; then cat /tmp/pyrra-crd-apply.out; exit 1; fi

applied="no"
$KC apply -f "$PYRRA_DIR" >/tmp/pyrra-apply.out 2>&1 && applied="yes"
check "Manifests apply without errors" yes "$applied"
if [ "$applied" != "yes" ]; then cat /tmp/pyrra-apply.out; exit 1; fi

est="$($KC get crd servicelevelobjectives.pyrra.dev -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null)"
check "CRD servicelevelobjectives.pyrra.dev is established" True "$est"

echo "Waiting for Pyrra (the first start pulls the image)..."
for d in pyrra-kubernetes pyrra-api; do
  rolled="no"
  $K rollout status "deployment/$d" --timeout=240s >/dev/null 2>&1 && rolled="yes"
  check "Deployment $d rolls out" yes "$rolled"
  if [ "$rolled" != "yes" ]; then
    $K get pods
    $K describe pod -l "app.kubernetes.io/component=${d#pyrra-}" | tail -20
    echo "If the image cannot be pulled, check that $EXPECTED_IMAGE exists."
    exit 1
  fi
done

images="$($K get deployment pyrra-kubernetes pyrra-api -o jsonpath='{range .items[*]}{.spec.template.spec.containers[0].image}{"\n"}{end}' 2>/dev/null | sort -u)"
check "Both deployments use $EXPECTED_IMAGE" "$EXPECTED_IMAGE" "$images"

code="000"
for _ in $(seq 1 30); do
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$UI/")"
  [ "$code" = "200" ] && break
  sleep 1
done
check "Pyrra UI responds through node port 30099" 200 "$code"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Pyrra Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **Pyrra image:** \`$EXPECTED_IMAGE\`
- **Manifests:** \`monitoring/pyrra/\`
- **Command:** \`tests/pyrra-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

No SLOs are defined yet at this step.

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
