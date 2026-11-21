# Kubernetes Deployment Test Results

- **Date (UTC):** 2026-11-21 16:07:41
- **Kubernetes server:** v1.37.0
- **Image:** `shop-api:1.0.0` (loaded into kind, not pulled from a registry)
- **Manifests:** `k8s/`, applied with `kubectl apply` (Argo CD takes over this role later)
- **Command:** `tests/k8s-test.sh`
- **Result:** 13 of 13 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Image is loaded into the cluster | yes | yes | PASS |
| Manifests apply without errors | yes | yes | PASS |
| Deployment rolls out | yes | yes | PASS |
| Deployment has 1 ready replica | 1 | 1 | PASS |
| Container runs as UID 10001 | 10001 | 10001 | PASS |
| GET /health through the Service returns 200 | 200 | 200 | PASS |
| POST /checkout through the Service returns 200 | 200 | 200 | PASS |
| GET /metrics through the Service returns 200 | 200 | 200 | PASS |
| GET /admin/faults returns 200 (ADMIN_ENABLED=true) | 200 | 200 | PASS |
| POST /admin/crash returns 202 | 202 | 202 | PASS |
| Kubernetes restarts the container (restart count +1) | 1 | 1 | PASS |
| Last container exit code is 3 | 3 | 3 | PASS |
| Pod is Ready again after the restart | true | true | PASS |

The crash test is a process crash handled by the container restart policy.
It is not a CrashLoopBackOff, which is tested separately later.

## Resources in the shop namespace (after the crash test)

```
NAME                           READY   STATUS    RESTARTS     AGE   IP           NODE                          NOMINATED NODE   READINESS GATES
pod/shop-api-c698b845b-n7vrr   1/1     Running   1 (9s ago)   19s   10.244.0.5   cloudnova-sre-control-plane   <none>           <none>

NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/shop-api   ClusterIP   10.96.116.71   <none>        8080/TCP   19s   app.kubernetes.io/name=shop-api
```
