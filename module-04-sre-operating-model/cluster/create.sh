#!/usr/bin/env bash
# Creates the local kind cluster used by the project (skips if it exists).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER="cloudnova-sre"

for tool in docker kind kubectl; do
  command -v "$tool" >/dev/null || { echo "$tool is not installed."; exit 1; }
done
docker info >/dev/null 2>&1 || { echo "Docker is not reachable."; exit 1; }

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' already exists."
else
  kind create cluster --name "$CLUSTER" --config "$SCRIPT_DIR/kind-config.yaml"
fi

kubectl --context "kind-$CLUSTER" wait --for=condition=Ready node --all --timeout=120s
kubectl --context "kind-$CLUSTER" get nodes
