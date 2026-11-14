import time
import urllib.request
import urllib.error
from datetime import datetime, timezone

URL = "http://localhost:5000/orders"
TOTAL_REQUESTS = 50

results = []

print(f"Sending {TOTAL_REQUESTS} requests to {URL}...\n")

for request_number in range(1, TOTAL_REQUESTS + 1):
    start_time = time.perf_counter()

    try:
        with urllib.request.urlopen(URL, timeout=5) as response:
            status_code = response.status
            response.read()

    except urllib.error.HTTPError as error:
        status_code = error.code
        error.read()

    except Exception as error:
        status_code = 0
        print(f"Request {request_number} failed: {error}")

    end_time = time.perf_counter()
    response_time_ms = (end_time - start_time) * 1000

    results.append({
        "request": request_number,
        "status": status_code,
        "response_time": response_time_ms
    })

    print(
        f"Request {request_number:02d} | "
        f"Status: {status_code} | "
        f"Response Time: {response_time_ms:.2f} ms"
    )

timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

with open("TrafficResultsLog.md", "w", encoding="utf-8") as file:
    file.write("# Traffic Results Log\n\n")
    file.write(f"- **Generated at:** {timestamp}\n")
    file.write(f"- **Endpoint:** `{URL}`\n")
    file.write(f"- **Total Requests:** {TOTAL_REQUESTS}\n\n")

    file.write("| Request | HTTP Status Code | Response Time (ms) |\n")
    file.write("|---:|---:|---:|\n")

    for result in results:
        file.write(
            f"| {result['request']} "
            f"| {result['status']} "
            f"| {result['response_time']:.2f} |\n"
        )

print("\nTraffic generation completed.")
print("Results saved to TrafficResultsLog.md")
