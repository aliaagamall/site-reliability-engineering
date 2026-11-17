import os
import time
import urllib.error
import urllib.request
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

TARGET = os.getenv("TARGET", "http://slo-demo-app:8000/orders")
DURATION = int(os.getenv("DURATION", "120")) 
WORKERS = int(os.getenv("WORKERS", "40"))  # parallel clients

deadline = time.time() + DURATION
print(f"Spike traffic: {WORKERS} parallel clients for {DURATION}s")


def worker():
    counts = Counter()
    while time.time() < deadline:
        try:
            code = urllib.request.urlopen(TARGET, timeout=10).status
        except urllib.error.HTTPError as exc:
            code = exc.code
        except Exception:
            code = "error"
        counts[code] += 1
    return counts


total = Counter()
with ThreadPoolExecutor(max_workers=WORKERS) as pool:
    for result in pool.map(lambda _: worker(), range(WORKERS)):
        total.update(result)

print("Done. Responses:", dict(total))