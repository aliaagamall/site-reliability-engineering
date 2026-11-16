#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${GITOPS_REPO_DIR:?set GITOPS_REPO_DIR to your SRE repo root}"
cd "$REPO_DIR"

# only revert if the latest commit is the faulty one
if ! git log -1 --pretty=%s | grep -q "broken tag"; then
  echo "Latest commit is not the faulty one. Aborting."
  exit 1
fi

git revert --no-edit HEAD
git push origin main
git log --oneline -5