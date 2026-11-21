#!/usr/bin/env bash
# Checks the local kind cluster and writes a Markdown report.
# Run cluster/create.sh first.
#
# Usage:    module-04-sre-operating-model/tests/cluster-test.sh
# Optional: REPORT (output path)

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER="cloudnova-sre"
K="kubectl --context kind-$CLUSTER"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/cluster-test.md}"
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

exists="no"
kind get clusters 2>/dev/null | grep -qx "$CLUSTER" && exists="yes"
check "Cluster '$CLUSTER' exists" yes "$exists"
if [ "$exists" != "yes" ]; then
  echo "Run cluster/create.sh first."
  exit 1
fi

reachable="no"
$K get --raw /readyz >/dev/null 2>&1 && reachable="yes"
check "API server is reachable and ready" yes "$reachable"

nodes="$($K get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
check "Cluster has 1 node" 1 "$nodes"
ready_nodes="$($K get nodes -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' 2>/dev/null | grep -c True)"
check "All nodes are Ready" "$nodes" "$ready_nodes"

pods_ready="no"
$K wait --for=condition=Ready pod --all -n kube-system --timeout=120s >/dev/null 2>&1 && pods_ready="yes"
check "All kube-system pods become Ready" yes "$pods_ready"
not_running="$($K get pods -n kube-system --no-headers 2>/dev/null | awk '$3 != "Running"' | wc -l | tr -d ' ')"
check "kube-system pods not in Running state" 0 "$not_running"

sc="no"
$K get storageclass -o jsonpath='{range .items[*]}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' 2>/dev/null | grep -qx true && sc="yes"
check "A default StorageClass exists" yes "$sc"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
FENCE='```'
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# Cluster Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **kind:** $(kind --version)
- **kubectl client:** $(kubectl version --client 2>/dev/null | head -1)
- **Kubernetes server:** $($K version 2>/dev/null | awk '/Server Version/ {print $3}')
- **Cluster:** \`$CLUSTER\` (one control-plane node)
- **Command:** \`tests/cluster-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

## Nodes

$FENCE
$($K get nodes -o wide 2>&1)
$FENCE

## kube-system pods

$FENCE
$($K get pods -n kube-system 2>&1)
$FENCE
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
