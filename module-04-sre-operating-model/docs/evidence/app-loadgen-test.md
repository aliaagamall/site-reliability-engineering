# Load Generator Test Results

- **Date (UTC):** 2026-11-21 13:33:17
- **Python:** Python 3.12.3
- **Environment:** local run, `app/loadgen.py` against `shop-api` on Gunicorn
- **Command:** `app/loadgen-test.sh`
- **Result:** 12 of 12 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Normal run exits with code 0 | 0 | 0 | PASS |
| Sends about 100 requests (95 to 105) | yes | yes | PASS |
| All requests return 200 | 100 | 100 | PASS |
| At least 95% of requests finish within 300 ms | yes | yes | PASS |
| App metrics count the same 200 responses | 100 | 100 | PASS |
| With error_rate=1.0 all requests return 500 | yes | yes | PASS |
| App metrics count the same 500 responses | 20 | 20 | PASS |
| Stops cleanly on SIGINT (exit code 0) | 0 | 0 | PASS |
| Prints a summary when stopped | yes | yes | PASS |
| Unreachable app: loadgen still exits with code 0 | 0 | 0 | PASS |
| Unreachable app: every request is counted as error | yes | yes | PASS |
| Invalid --rate 0 is rejected (exit code 2) | 2 | 2 | PASS |

## Sample output

Normal traffic: `loadgen.py --rate 20 --duration 5`

```
Sending 20 req/s to http://127.0.0.1:8080/checkout for 5 s
Summary
  duration: 5.0 s
  requests sent: 100
  status 200: 100
  latency p50 / p95 / max: 48 / 80 / 84 ms
  within 300 ms: 100.0%
```

Failure traffic with `error_rate=1.0`: `loadgen.py --rate 10 --duration 2`

```
Sending 10 req/s to http://127.0.0.1:8080/checkout for 2 s
Summary
  duration: 2.0 s
  requests sent: 20
  status 500: 20
  latency p50 / p95 / max: 40 / 85 / 96 ms
  within 300 ms: 100.0%
```
