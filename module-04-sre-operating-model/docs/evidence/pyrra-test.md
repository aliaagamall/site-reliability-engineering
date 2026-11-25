# Pyrra Test Results

- **Date (UTC):** 2026-11-25 11:54:21
- **Kubernetes server:** v1.37.0
- **Pyrra image:** `ghcr.io/pyrra-dev/pyrra:v0.10.2`
- **Manifests:** `monitoring/pyrra/`
- **Command:** `tests/pyrra-test.sh`
- **Result:** 7 of 7 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| CRD applies without errors | yes | yes | PASS |
| Manifests apply without errors | yes | yes | PASS |
| CRD servicelevelobjectives.pyrra.dev is established | True | True | PASS |
| Deployment pyrra-kubernetes rolls out | yes | yes | PASS |
| Deployment pyrra-api rolls out | yes | yes | PASS |
| Both deployments use ghcr.io/pyrra-dev/pyrra:v0.10.2 | ghcr.io/pyrra-dev/pyrra:v0.10.2 | ghcr.io/pyrra-dev/pyrra:v0.10.2 | PASS |
| Pyrra UI responds through node port 30099 | 200 | 200 | PASS |

No SLOs are defined yet at this step.

## Pods in the monitoring namespace

```
NAME                                  READY   STATUS    RESTARTS      AGE
kube-state-metrics-75f8b47b8c-xjqds   1/1     Running   2 (20m ago)   23h
prometheus-main-0                     2/2     Running   2 (20m ago)   23h
prometheus-operator-66cffdb58-hhb7b   1/1     Running   1 (20m ago)   23h
pyrra-api-76db757574-nqqb2            1/1     Running   0             7m9s
pyrra-kubernetes-5649b8c6db-gxwqh     1/1     Running   0             7m9s
```

## Host memory

```
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       1.8Gi       1.9Gi        16Mi       4.1Gi       5.9Gi
Swap:          2.0Gi          0B       2.0Gi
```
