# SLI Measurement Report

- **Generated at:** 2026-11-11 18:13:19 UTC
- **Source:** `TrafficResultsLog.md`

## Request Summary

| Metric | Value |
|---|---:|
| Total Requests | 50 |
| Successful Requests | 46 |
| Failed Requests | 4 |
| Requests Completed Within 500 ms | 25 |

## Service Level Indicators

| SLI | Calculation | Result |
|---|---|---:|
| Availability | Successful Requests / Total Requests | 92.00% |
| Error Rate | Failed Requests / Total Requests | 8.00% |
| Latency | Requests Within 500 ms / Total Requests | 50.00% |

## Measurement Definitions

- **Availability SLI:** Percentage of requests that returned a successful HTTP status.
- **Error Rate SLI:** Percentage of requests that failed.
- **Latency SLI:** Percentage of requests completed within 500 milliseconds.

## Measurement Notes

- Total requests: 50
- HTTP 2xx and 3xx responses are counted as successful.
- HTTP 4xx and 5xx responses are counted as failed.
- Requests with a connection or timeout error are also counted as failed.
- The latency threshold is 500 milliseconds.
- Results depend on the application's randomized latency and failure behavior.
