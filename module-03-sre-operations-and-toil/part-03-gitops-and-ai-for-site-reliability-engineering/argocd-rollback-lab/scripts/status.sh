#!/usr/bin/env bash
set -euo pipefail

echo "== Argo CD application =="
kubectl get app rollback-demo -n argocd

echo
echo "== Deployment =="
kubectl get deploy rollback-demo -o wide

echo
echo "== Pods =="
kubectl get pods -l app=rollback-demo

echo
echo "== Image in cluster =="
kubectl get deploy rollback-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
echo