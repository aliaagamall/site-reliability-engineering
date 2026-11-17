import os
import time
import urllib.error
import urllib.request

TARGET = os.getenv("TARGET", "http://slo-demo-app:8000/orders")
DURATION = int(os.getenv("DURATION", "120")) 
INTERVAL = float(os.getenv("INTERVAL", "1.0")) 

counts = {}
deadline = time.time() + DURATION
print(f"Normal traffic: 1 request every {INTERVAL}s for {DURATION}s")

while time.time() < deadline:
    try:
        code = urllib.request.urlopen(TARGET, timeout=5).status
    except urllib.error.HTTPError as exc:
        code = exc.code
    except Exception as exc:
        code = "error"
        print("request failed:", exc)
    counts[code] = counts.get(code, 0) + 1
    time.sleep(INTERVAL)

print("Done. Responses:", counts)