#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

wait_for() {
  local name=$1 url=$2
  printf "Waiting for %s " "$name"
  for _ in $(seq 1 60); do
    if curl -fs "$url" >/dev/null; then echo "OK"; return 0; fi
    printf "."; sleep 2
  done
  echo "FAILED"; exit 1
}

wait_target_up() {
  printf "Waiting for Prometheus target slo-demo-app "
  for _ in $(seq 1 30); do
    if curl -fsG localhost:9090/api/v1/query \
        --data-urlencode 'query=up{job="slo-demo-app"}' | grep -q '"1"\]'; then
      echo "UP"; return 0
    fi
    printf "."; sleep 2
  done
  echo "FAILED"; exit 1
}

case "${1:-up}" in
  up)
    docker compose up -d --build
    wait_for "app"        http://localhost:8000/
    wait_for "prometheus" http://localhost:9090/-/ready
    wait_for "grafana"    http://localhost:3000/api/health
    wait_target_up
    bash scripts/generate-traffic.sh 200
    echo
    echo "App         : http://localhost:8000/orders"
    echo "Metrics     : http://localhost:8000/metrics"
    echo "Prometheus  : http://localhost:9090/targets"
    echo "Dashboard   : http://localhost:3000/d/slo-dashboard  (admin / admin)"
    ;;
  traffic)
    bash scripts/generate-traffic.sh "${2:-100}"
    ;;
  status)
    docker compose ps
    ;;
  down)
    docker compose down -v
    ;;
  *)
    echo "Usage: bash run.sh [up|traffic [N]|status|down]"
    exit 1
    ;;
esac