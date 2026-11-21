import logging
import os
import random
import signal
import threading
import time

from flask import Flask, abort, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

app = Flask(__name__)
app.logger.setLevel(logging.INFO)

REQUESTS = Counter(
    "http_requests_total",
    "HTTP requests by endpoint and status",
    ["endpoint", "status"],
)
DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["endpoint"],
    buckets=(0.05, 0.1, 0.2, 0.3, 0.5, 1.0, 2.5, 5.0),
)

# Fault injection state 
FAULTS = {"error_rate": 0.0, "latency_ms": 0, "db_down": False}
FAULTS_LOCK = threading.Lock()


def current_faults():
    with FAULTS_LOCK:
        return dict(FAULTS)


def admin_enabled():
    return os.environ.get("ADMIN_ENABLED", "false").lower() == "true"


def validate_faults(data):
    """Return an error message, or None if the update is valid."""
    unknown = set(data) - set(FAULTS)
    if unknown:
        return f"unknown fault(s): {', '.join(sorted(unknown))}"
    if "error_rate" in data:
        v = data["error_rate"]
        if isinstance(v, bool) or not isinstance(v, (int, float)) or not 0 <= v <= 1:
            return "error_rate must be a number between 0 and 1"
    if "latency_ms" in data:
        v = data["latency_ms"]
        if isinstance(v, bool) or not isinstance(v, int) or not 0 <= v <= 10000:
            return "latency_ms must be an integer between 0 and 10000"
    if "db_down" in data and not isinstance(data["db_down"], bool):
        return "db_down must be true or false"
    return None


def process_checkout():
    payload = request.get_json(silent=True)
    if (
        not isinstance(payload, dict)
        or not isinstance(payload.get("item"), str)
        or not payload["item"]
    ):
        return 400, {"error": "body must be JSON with a non-empty 'item'"}

    faults = current_faults()
    # Normal processing time plus any injected latency.
    time.sleep(random.uniform(0.01, 0.08) + faults["latency_ms"] / 1000)

    if faults["db_down"]:
        return 503, {"error": "database unavailable"}
    if random.random() < faults["error_rate"]:
        return 500, {"error": "internal error"}
    return 200, {"status": "ok", "item": payload["item"]}


@app.post("/checkout")
def checkout():
    start = time.perf_counter()
    try:
        status, body = process_checkout()
    except Exception:
        app.logger.exception("checkout failed")
        status, body = 500, {"error": "internal error"}
    DURATION.labels(endpoint="/checkout").observe(time.perf_counter() - start)
    REQUESTS.labels(endpoint="/checkout", status=str(status)).inc()
    return jsonify(body), status


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


# Internal testing endpoints. Disabled unless ADMIN_ENABLED=true.
@app.route("/admin/faults", methods=["GET", "POST"])
def admin_faults():
    if not admin_enabled():
        abort(404)
    if request.method == "POST":
        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            return jsonify({"error": "body must be a JSON object"}), 400
        error = validate_faults(data)
        if error:
            return jsonify({"error": error}), 400
        with FAULTS_LOCK:
            FAULTS.update(data)
        app.logger.warning("faults updated: %s", current_faults())
    return jsonify(current_faults())


def terminate_process(kill_master):
    if kill_master:
        os.kill(os.getppid(), signal.SIGKILL)
    os._exit(1)


@app.post("/admin/crash")
def admin_crash():
    if not admin_enabled():
        abort(404)
    app.logger.warning("crash requested: terminating the process")
    under_gunicorn = request.environ.get("SERVER_SOFTWARE", "").startswith("gunicorn")
    threading.Timer(0.5, terminate_process, args=(under_gunicorn,)).start()
    return jsonify({"status": "crashing"}), 202
