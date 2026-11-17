import random
import threading
import time

from flask import Flask, Response, jsonify
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)

REQUESTS = Counter("http_requests", "Total HTTP requests", ["method", "path", "code"])
LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["path"],
    buckets=(0.05, 0.1, 0.25, 0.5, 1, 2.5, 5),
)

REQUESTS.labels("GET", "/orders", "200")
REQUESTS.labels("GET", "/orders", "500")

inflight = 0
lock = threading.Lock()


@app.get("/orders")
def orders():
    global inflight
    with lock:
        inflight += 1
        load = inflight
    start = time.perf_counter()
    code = 200
    try:
        # Base latency, plus extra delay when many requests overlap
        time.sleep(random.uniform(0.02, 0.08) + max(0, load - 5) * 0.04)
        # Base error rate, plus extra errors under heavy load
        error_probability = 0.005 + (0.15 if load > 15 else 0.0)
        if random.random() < error_probability:
            code = 500
    finally:
        with lock:
            inflight -= 1
        LATENCY.labels("/orders").observe(time.perf_counter() - start)
        REQUESTS.labels("GET", "/orders", str(code)).inc()

    if code == 500:
        return jsonify(error="internal error"), 500
    return jsonify(orders=[]), 200


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, threaded=True)