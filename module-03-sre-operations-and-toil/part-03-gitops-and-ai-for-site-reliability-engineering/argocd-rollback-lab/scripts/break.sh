#!/usr/bin/env bash
set -euo pipefail

# Repo root of the SRE repo 
REPO_DIR="${GITOPS_REPO_DIR:?set GITOPS_REPO_DIR to your SRE repo root}"
MANIFEST="module-03-sre-operations-and-toil/part-03-gitops-and-ai-for-site-reliability-engineering/argocd-rollback-lab/gitops-repo/manifests/deployment.yaml"

cd "$REPO_DIR"

sed -i.bak 's|image: nginx:.*|image: nginx:does-not-exist-99|' "$MANIFEST"
rm "$MANIFEST.bak"

git add "$MANIFEST"
git commit -m "feat(app): update nginx image to broken tag"
git push origin main