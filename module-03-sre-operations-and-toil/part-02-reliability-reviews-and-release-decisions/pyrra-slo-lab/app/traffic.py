import os
import time
import urllib.error
import urllib.request

TARGET = os.getenv("TARGET", "http://slo-demo-app:8000/orders")
RPS = float(os.getenv("RPS", "10"))

while True:
    try:
        urllib.request.urlopen(TARGET, timeout=2).read()
    except urllib.error.HTTPError:
        pass  # 5xx is expected, the app counts it
    except Exception as exc:
        print("request failed:", exc)
    time.sleep(1 / RPS)