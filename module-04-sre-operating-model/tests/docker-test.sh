#!/usr/bin/env bash
# Builds the shop-api image, runs it, tests it, and writes a Markdown report.

set -uo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/../app" && pwd)"
IMAGE="shop-api:1.0.0"
NAME="shop-api-test"
PORT="${PORT:-8080}"
REPORT="${REPORT:-$SCRIPT_DIR/../docs/evidence/tests/app-docker-test.md}"
BASE="http://127.0.0.1:$PORT"
RESULTS=()
FAILED=0

cleanup() { docker rm -f "$NAME" >/dev/null 2>&1; }
trap cleanup EXIT

code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X "$1" "$2"; }

check() {
  local result="PASS"
  if [ "$2" != "$3" ]; then
    result="FAIL"
    FAILED=$((FAILED + 1))
  fi
  RESULTS+=("| $1 | $2 | $3 | $result |")
  printf '%-5s %s (expected %s, got %s)\n' "$result" "$1" "$2" "$3"
}

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not reachable. Start Docker or check your permissions."
  exit 1
fi
if [ "$(code GET "$BASE/health")" != "000" ]; then
  echo "Port $PORT is already in use. Stop the process using it and run again."
  exit 1
fi

cleanup
echo "Building $IMAGE..."
if ! docker build -q -t "$IMAGE" "$APP_DIR" >/dev/null; then
  echo "Image build failed."
  exit 1
fi
check "Image builds" yes yes
SIZE="$(docker image ls "$IMAGE" --format '{{.Size}}')"

echo "Starting container..."
docker run -d --name "$NAME" -p "$PORT:8080" -e ADMIN_ENABLED=true "$IMAGE" >/dev/null
up="no"
for _ in $(seq 1 40); do
  [ "$(code GET "$BASE/health")" = "200" ] && { up="yes"; break; }
  sleep 0.5
done
check "Container starts and /health responds" yes "$up"
if [ "$up" != "yes" ]; then
  docker logs "$NAME"
  exit 1
fi

check "POST /checkout returns 200" 200 \
  "$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{"item":"book"}' "$BASE/checkout")"
check "GET /metrics returns 200" 200 "$(code GET "$BASE/metrics")"
check "GET /admin/faults returns 200 when ADMIN_ENABLED=true" 200 "$(code GET "$BASE/admin/faults")"

uid="$(docker exec "$NAME" id -u 2>/dev/null)"
check "Container runs as non-root user" 10001 "$uid"

check "POST /admin/crash returns 202" 202 "$(code POST "$BASE/admin/crash")"
stopped="no"
for _ in $(seq 1 20); do
  sleep 0.5
  if [ "$(docker inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" = "false" ]; then
    stopped="yes"
    break
  fi
done
check "Container stops after the crash request" yes "$stopped"
exit_code="$(docker inspect -f '{{.State.ExitCode}}' "$NAME" 2>/dev/null)"
nonzero="no"
[ -n "$exit_code" ] && [ "$exit_code" != "0" ] && nonzero="yes"
check "Container exits with a non-zero exit code" yes "$nonzero"

TOTAL=${#RESULTS[@]}
PASSED=$((TOTAL - FAILED))
mkdir -p "$(dirname "$REPORT")"
{
  cat << REPORT_EOF
# shop-api Docker Test Results

- **Date (UTC):** $(date -u '+%Y-%m-%d %H:%M:%S')
- **Docker:** $(docker --version)
- **Image:** \`$IMAGE\` ($SIZE)
- **Container exit code after crash:** $exit_code
- **Command:** \`tests/docker-test.sh\`
- **Result:** $PASSED of $TOTAL checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
REPORT_EOF
  printf '%s\n' "${RESULTS[@]}"
  cat << REPORT_EOF

The crash test stops the container. This is a process crash, not a Kubernetes
CrashLoopBackOff, which is tested later in the cluster.
REPORT_EOF
} > "$REPORT"

echo
echo "$PASSED of $TOTAL checks passed. Report: $REPORT"
[ "$FAILED" -eq 0 ]
