#!/usr/bin/env bash
set -euo pipefail

# Usage: generate-traffic.sh [number_of_requests]
N="${1:-100}"
URL="${APP_URL:-http://localhost:8000/orders}"

echo "Sending $N requests to $URL"

# 5 parallel workers, then count responses per status code
seq "$N" | xargs -P 5 -I{} curl -s -o /dev/null -w "%{http_code}\n" "$URL" | sort | uniq -c