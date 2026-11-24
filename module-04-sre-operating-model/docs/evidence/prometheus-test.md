# Prometheus Test Results

- **Date (UTC):** 2026-11-24 12:16:56
- **Kubernetes server:** v1.37.0
- **Prometheus image:** `quay.io/prometheus/prometheus:v3.14.0`
- **Manifests:** `monitoring/prometheus/`
- **Command:** `tests/prometheus-test.sh`
- **Result:** 7 of 7 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Manifests apply without errors | yes | yes | PASS |
| Prometheus pod becomes Ready | yes | yes | PASS |
| Prometheus responds through node port 30900 | 200 | 200 | PASS |
| Target shop-api is up | 1 | 1 | PASS |
| http_requests_total{endpoint="/checkout",status="200"} is queryable and counts the requests | yes | yes | PASS |
| The le="0.3" latency bucket is queryable | 1 | 1 | PASS |
| No metrics were relabeled to exported_endpoint | none | none | PASS |

Prometheus has no persistent volume, so its data is lost if the pod restarts.

## Pods in the monitoring namespace

```
NAME                                  READY   STATUS    RESTARTS   AGE
prometheus-main-0                     2/2     Running   0          2m32s
prometheus-operator-66cffdb58-hhb7b   1/1     Running   0          9m58s
```

## Host memory

```
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       1.9Gi       133Mi        17Mi       5.9Gi       5.8Gi
Swap:          2.0Gi       220Ki       2.0Gi
```
