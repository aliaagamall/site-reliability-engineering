#!/usr/bin/env python3

import argparse
import json
import signal
import threading
import time
import urllib.error
import urllib.request
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

LATENCY_SLO_SECONDS = 0.3
REPORT_EVERY_SECONDS = 10


class Stats:
    def __init__(self):
        self._lock = threading.Lock()
        self._statuses = Counter()
        self._latencies = []

    def record(self, status, seconds):
        with self._lock:
            self._statuses[status] += 1
            self._latencies.append(seconds)

    def snapshot(self):
        with self._lock:
            return Counter(self._statuses), list(self._latencies)


def send(url, stats):
    request = urllib.request.Request(
        url + "/checkout",
        data=json.dumps({"item": "book"}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    start = time.perf_counter()
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            response.read()
            status = str(response.status)
    except urllib.error.HTTPError as error:
        status = str(error.code)
    except Exception:
        status = "error"  # connection refused, timeout, and similar
    stats.record(status, time.perf_counter() - start)


def percentile(sorted_values, p):
    index = int(round(p / 100 * (len(sorted_values) - 1)))
    return sorted_values[index]


def print_summary(stats, elapsed):
    statuses, latencies = stats.snapshot()
    total = len(latencies)
    print("Summary")
    print(f"  duration: {elapsed:.1f} s")
    print(f"  requests sent: {total}")
    for status in sorted(statuses):
        print(f"  status {status}: {statuses[status]}")
    if total:
        ordered = sorted(latencies)
        within = sum(1 for v in ordered if v <= LATENCY_SLO_SECONDS) / total * 100
        print(
            "  latency p50 / p95 / max: "
            f"{percentile(ordered, 50) * 1000:.0f} / "
            f"{percentile(ordered, 95) * 1000:.0f} / "
            f"{ordered[-1] * 1000:.0f} ms"
        )
        print(f"  within 300 ms: {within:.1f}%")


def parse_args():
    parser = argparse.ArgumentParser(description="Send POST /checkout traffic to shop-api.")
    parser.add_argument("--url", default="http://127.0.0.1:8080", help="base URL of shop-api")
    parser.add_argument("--rate", type=float, default=10.0, help="requests per second")
    parser.add_argument(
        "--duration", type=float, default=0, help="seconds to run (0 = until Ctrl+C)"
    )
    args = parser.parse_args()
    if args.rate <= 0:
        parser.error("--rate must be greater than 0")
    if args.duration < 0:
        parser.error("--duration must not be negative")
    return args


def main():
    args = parse_args()
    stats = Stats()
    stop = threading.Event()

    def handle_signal(signum, frame):
        stop.set()

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    interval = 1.0 / args.rate
    limit = f" for {args.duration:g} s" if args.duration else " (Ctrl+C to stop)"
    print(f"Sending {args.rate:g} req/s to {args.url}/checkout{limit}")

    start = time.perf_counter()
    next_send = start
    last_report = start
    # Requests are sent on schedule even when responses are slow.
    with ThreadPoolExecutor(max_workers=64) as executor:
        while not stop.is_set():
            now = time.perf_counter()
            if args.duration and now - start >= args.duration:
                break
            executor.submit(send, args.url, stats)
            next_send += interval
            if next_send < now - 1:  # far behind schedule: do not burst to catch up
                next_send = now
            stop.wait(max(0.0, next_send - time.perf_counter()))
            now = time.perf_counter()
            if now - last_report >= REPORT_EVERY_SECONDS:
                statuses, latencies = stats.snapshot()
                counts = " ".join(f"{k}={statuses[k]}" for k in sorted(statuses))
                print(f"[{now - start:.0f}s] completed={len(latencies)} {counts}")
                last_report = now
    print_summary(stats, time.perf_counter() - start)


if __name__ == "__main__":
    main()
