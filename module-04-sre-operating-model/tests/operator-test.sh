#!/usr/bin/env bash
# Installs the Prometheus Operator in the kind cluster, verifies it, and writes a report.
# Run cluster/create.sh first. Needs internet access to download the pinned bundle.
#
# Usage:    module-04-sre-operating-model/tests/operator-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPERATOR_DIR="$(cd "$SCRIPT_DIR/../monitoring/operator" && pwd)"
CLUSTER="cloudnova-sre"
KC="kubectl --context kind-$CLUSTER"
K="$KC -n monitoring"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/operator-test.md}"
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

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' not found. Run cluster/create.sh first."
  exit 1
fi

echo "Applying the Prometheus Operator (downloads the bundle)..."
applied="no"
$KC apply --server-side -k "$OPERATOR_DIR" >/tmp/operator-apply.out 2>&1 && applied="yes"
check "Manifests apply without errors" "yes" "$applied"
if [ "$applied" != "yes" ]; then
  cat /tmp/operator-apply.out
  exit 1
fi

rolled="no"
$K rollout status deployment/prometheus-operator --timeout=180s >/dev/null 2>&1 && rolled="yes"
check "Operator deployment rolls out" yes "$rolled"

ns="no"
$KC get namespace monitoring >/dev/null 2>&1 && ns="yes"
check "Namespace 'monitoring' exists" yes "$ns"

for crd in prometheuses servicemonitors prometheusrules alertmanagers; do
  est="$($KC get crd "$crd.monitoring.coreos.com" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null)"
  check "CRD $crd is established" True "$est"
done

check "Operator ClusterRoleBinding targets namespace monitoring" monitoring \
  "$($KC get clusterrolebinding prometheus-operator -o jsonpath='{.subjects[0].namespace}' 2>/dev/null)"

IMAGE="$($K get deployment prometheus-operator -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Prometheus Operator Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Kubernetes server:** $($KC version 2>/dev/null | awk '/Server Version/ {print $3}')
- **Operator image:** \`$IMAGE\`
- **Manifests:** \`monitoring/operator/\`, applied with \`kubectl apply --server-side -k\`
- **Command:** \`tests/operator-test.sh\`
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
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
