import os
import random

from flask import Flask, Response, jsonify
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

app = Flask(__name__)

# Exposed as http_requests_total
REQUESTS = Counter("http_requests", "Total HTTP requests", ["method", "path", "code"])

# Create both series at 0 so rate() works from the start
REQUESTS.labels("GET", "/orders", "200")
REQUESTS.labels("GET", "/orders", "500")

state = {"error_rate": float(os.getenv("ERROR_RATE", "0.002"))}


@app.get("/orders")
def orders():
    if random.random() < state["error_rate"]:
        REQUESTS.labels("GET", "/orders", "500").inc()
        return jsonify(error="internal error"), 500
    REQUESTS.labels("GET", "/orders", "200").inc()
    return jsonify(orders=[]), 200


@app.get("/admin/error-rate")
def get_error_rate():
    return jsonify(error_rate=state["error_rate"])


@app.post("/admin/error-rate/<rate>")
def set_error_rate(rate):
    state["error_rate"] = max(0.0, min(1.0, float(rate)))
    return jsonify(error_rate=state["error_rate"])


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)