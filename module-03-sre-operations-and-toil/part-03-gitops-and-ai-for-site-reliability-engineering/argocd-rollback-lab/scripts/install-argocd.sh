#!/usr/bin/env bash
set -euo pipefail

# Start the cluster and check the node
minikube start --driver=docker --cpus=2 --memory=4096
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes

# Install Argo CD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s
kubectl get pods -n argocd

echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo