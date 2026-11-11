from flask import Flask, jsonify
import random
import time

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify({
        "message": "SRE SLI/SLO Sample Application",
        "status": "running"
    })


@app.route("/orders")
def get_orders():
    response_time = random.uniform(0.1, 0.8)
    time.sleep(response_time)

    if random.random() < 0.08:
        return jsonify({
            "status": "error",
            "message": "Order service temporarily unavailable"
        }), 500

    return jsonify({
        "status": "success",
        "orders": [
            {"id": 1, "item": "Laptop"},
            {"id": 2, "item": "Keyboard"}
        ]
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
