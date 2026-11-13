import os
import random
import time

from flask import Flask, jsonify, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Probability of a simulated 500 error
ERROR_RATE = float(os.getenv("ERROR_RATE", "0.05"))

# Counts requests by method, endpoint and status
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)

# Stores request duration in latency buckets
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
    buckets=(0.05, 0.1, 0.25, 0.5, 0.75, 1, 2, 5),
)


@app.route("/")
def home():
    return jsonify(message="SLO demo app is running")


@app.route("/orders")
def orders():
    start = time.time()

    # Simulate variable latency
    time.sleep(random.uniform(0.05, 0.8))

    # Simulate occasional failures
    if random.random() < ERROR_RATE:
        status = 500
        body = {"error": "internal server error"}
    else:
        status = 200
        body = {
            "order_id": random.randint(1000, 9999),
            "items": random.randint(1, 5),
            "total": round(random.uniform(10, 500), 2),
        }

    REQUEST_LATENCY.labels("/orders").observe(time.time() - start)
    REQUEST_COUNT.labels("GET", "/orders", str(status)).inc()
    return jsonify(body), status


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)