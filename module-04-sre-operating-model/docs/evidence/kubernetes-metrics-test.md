# Kubernetes Metrics Test Results

- **Date (UTC):** 2026-11-24 12:31:12
- **Kubernetes server:** v1.37.0
- **kube-state-metrics image:** `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.13.0`
- **Manifests:** `monitoring/kubernetes-metrics/`
- **Command:** `tests/kubernetes-metrics-test.sh`
- **Result:** 8 of 8 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Manifests apply without errors | yes | yes | PASS |
| kube-state-metrics deployment rolls out | yes | yes | PASS |
| Operator created the kubelet Service in kube-system | yes | yes | PASS |
| Target kube-state-metrics is up | 1 | 1 | PASS |
| kube-state-metrics keeps the namespace label (shop-api has 1 ready replica) | 1 | 1 | PASS |
| Container restart counts for shop-api are queryable | yes | yes | PASS |
| Kubelet cAdvisor target is up | 1 | 1 | PASS |
| cAdvisor memory for shop-api is queryable | yes | yes | PASS |

## Pods in the monitoring namespace

```
NAME                                  READY   STATUS    RESTARTS   AGE
kube-state-metrics-75f8b47b8c-xjqds   1/1     Running   0          2m24s
prometheus-main-0                     2/2     Running   0          16m
prometheus-operator-66cffdb58-hhb7b   1/1     Running   0          24m
```

## Host memory

```
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       1.9Gi       149Mi        17Mi       5.9Gi       5.8Gi
Swap:          2.0Gi       308Ki       2.0Gi
```
