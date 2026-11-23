# Prometheus Operator Test Results

- **Date (UTC):** 2026-11-23 22:55:22
- **Kubernetes server:** v1.37.0
- **Operator image:** `quay.io/prometheus-operator/prometheus-operator:v0.95.2`
- **Manifests:** `monitoring/operator/`, applied with `kubectl apply --server-side -k`
- **Command:** `tests/operator-test.sh`
- **Result:** 8 of 8 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Manifests apply without errors | yes | yes | PASS |
| Operator deployment rolls out | yes | yes | PASS |
| Namespace 'monitoring' exists | yes | yes | PASS |
| CRD prometheuses is established | True | True | PASS |
| CRD servicemonitors is established | True | True | PASS |
| CRD prometheusrules is established | True | True | PASS |
| CRD alertmanagers is established | True | True | PASS |
| Operator ClusterRoleBinding targets namespace monitoring | monitoring | monitoring | PASS |

## Pods in the monitoring namespace

```
NAME                                  READY   STATUS    RESTARTS   AGE
prometheus-operator-66cffdb58-xbkr2   1/1     Running   0          15s
```
