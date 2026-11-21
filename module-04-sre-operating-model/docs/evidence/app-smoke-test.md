# shop-api Smoke Test Results

- **Date (UTC):** 2026-11-21 04:50:31
- **Python:** Python 3.12.3
- **Gunicorn:** gunicorn (version 23.0.0)
- **Environment:** local run with Gunicorn (one worker, 8 threads), not yet in Docker or Kubernetes
- **Command:** `app/smoke-test.sh`
- **Result:** 23 of 23 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| GET /health returns 200 | 200 | 200 | PASS |
| POST /checkout with valid body returns 200 | 200 | 200 | PASS |
| POST /checkout with invalid body returns 400 | 400 | 400 | PASS |
| POST /admin/faults with error_rate=2 returns 400 | 400 | 400 | PASS |
| POST /admin/faults with unknown fault returns 400 | 400 | 400 | PASS |
| db_down: POST /checkout returns 503 | 503 | 503 | PASS |
| db_down: GET /health still returns 200 | 200 | 200 | PASS |
| db_down: GET /metrics still returns 200 | 200 | 200 | PASS |
| error_rate=1.0: POST /checkout returns 500 | 500 | 500 | PASS |
| latency_ms=500: POST /checkout returns 200 | 200 | 200 | PASS |
| latency_ms=500: request takes at least 0.5 s | yes | yes | PASS |
| After faults reset: POST /checkout returns 200 | 200 | 200 | PASS |
| Metrics contain /checkout status 200 | yes | yes | PASS |
| Metrics contain /checkout status 400 | yes | yes | PASS |
| Metrics contain /checkout status 500 | yes | yes | PASS |
| Metrics contain /checkout status 503 | yes | yes | PASS |
| Metrics contain the 0.3 s latency bucket | yes | yes | PASS |
| Metrics do not count /health requests | no | no | PASS |
| Admin disabled: GET /admin/faults returns 404 | 404 | 404 | PASS |
| Admin disabled: POST /admin/crash returns 404 | 404 | 404 | PASS |
| Admin disabled: app keeps running | 200 | 200 | PASS |
| POST /admin/crash returns 202 | 202 | 202 | PASS |
| Process stops after the crash request | yes | yes | PASS |

## Metrics sample

Taken from `/metrics` after the fault tests (before the crash test).

```
http_requests_total{endpoint="/checkout",status="200"} 3.0
http_requests_total{endpoint="/checkout",status="400"} 1.0
http_requests_total{endpoint="/checkout",status="503"} 1.0
http_requests_total{endpoint="/checkout",status="500"} 1.0
http_request_duration_seconds_bucket{endpoint="/checkout",le="0.3"} 5.0
http_request_duration_seconds_bucket{endpoint="/checkout",le="+Inf"} 6.0
http_request_duration_seconds_count{endpoint="/checkout"} 6.0
```
