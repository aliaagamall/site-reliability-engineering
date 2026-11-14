from datetime import datetime, timezone

LOG_FILE = "TrafficResultsLog.md"
REPORT_FILE = "SLI-Report.md"

results = []

with open(LOG_FILE, "r", encoding="utf-8") as file:
    for line in file:
        if line.startswith("|") and not line.startswith("|---"):
            columns = [column.strip() for column in line.strip().split("|")]

            if len(columns) == 5 and columns[1].isdigit():
                results.append({
                    "request": int(columns[1]),
                    "status": int(columns[2]),
                    "response_time": float(columns[3])
                })

total_requests = len(results)

successful_requests = sum(
    1 for result in results if 200 <= result["status"] < 400
)

failed_requests = total_requests - successful_requests

fast_requests = sum(
    1 for result in results if result["response_time"] <= 500
)

availability_sli = (
    successful_requests / total_requests * 100
    if total_requests else 0
)

error_rate_sli = (
    failed_requests / total_requests * 100
    if total_requests else 0
)

latency_sli = (
    fast_requests / total_requests * 100
    if total_requests else 0
)

timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

report = f"""# SLI Measurement Report

- **Generated at:** {timestamp}
- **Source:** `{LOG_FILE}`

## Request Summary

| Metric | Value |
|---|---:|
| Total Requests | {total_requests} |
| Successful Requests | {successful_requests} |
| Failed Requests | {failed_requests} |
| Requests Completed Within 500 ms | {fast_requests} |

## Service Level Indicators

| SLI | Calculation | Result |
|---|---|---:|
| Availability | Successful Requests / Total Requests | {availability_sli:.2f}% |
| Error Rate | Failed Requests / Total Requests | {error_rate_sli:.2f}% |
| Latency | Requests Within 500 ms / Total Requests | {latency_sli:.2f}% |

## Measurement Definitions

- **Availability SLI:** Percentage of requests that returned a successful HTTP status.
- **Error Rate SLI:** Percentage of requests that failed.
- **Latency SLI:** Percentage of requests completed within 500 milliseconds.

## Measurement Notes

- Total requests: {total_requests}
- HTTP 2xx and 3xx responses are counted as successful.
- HTTP 4xx and 5xx responses are counted as failed.
- Requests with a connection or timeout error are also counted as failed.
- The latency threshold is 500 milliseconds.
- Results depend on the application's randomized latency and failure behavior.
"""

with open(REPORT_FILE, "w", encoding="utf-8") as file:
    file.write(report)

print(report)
print(f"\nReport saved to {REPORT_FILE}")
