#!/usr/bin/env bash
set -euo pipefail

kubectl delete -f argocd/application.yaml --ignore-not-found
kubectl delete deploy,svc rollback-demo --ignore-not-found
kubectl delete namespace argocd --ignore-not-found

# Pass --cluster to delete the whole Minikube cluster
if [ "${1:-}" = "--cluster" ]; then
  minikube delete
fi