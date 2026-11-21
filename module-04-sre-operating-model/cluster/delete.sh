#!/usr/bin/env bash
# Deletes the local kind cluster and everything running in it.
set -euo pipefail
kind delete cluster --name cloudnova-sre
