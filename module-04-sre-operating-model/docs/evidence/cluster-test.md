# Cluster Test Results

- **Date (UTC):** 2026-11-21 15:57:03
- **kind:** kind version 0.33.0
- **kubectl client:** Client Version: v1.37.2
- **Kubernetes server:** v1.37.0
- **Cluster:** `cloudnova-sre` (one control-plane node)
- **Command:** `tests/cluster-test.sh`
- **Result:** 7 of 7 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Cluster 'cloudnova-sre' exists | yes | yes | PASS |
| API server is reachable and ready | yes | yes | PASS |
| Cluster has 1 node | 1 | 1 | PASS |
| All nodes are Ready | 1 | 1 | PASS |
| All kube-system pods become Ready | yes | yes | PASS |
| kube-system pods not in Running state | 0 | 0 | PASS |
| A default StorageClass exists | yes | yes | PASS |

## Nodes

```
NAME                          STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                              CONTAINER-RUNTIME
cloudnova-sre-control-plane   Ready    control-plane   51s   v1.37.0   172.24.0.2    <none>        Debian GNU/Linux 13 (trixie)   6.18.58.1-microsoft-standard-WSL2 (amd64)   containerd://2.3.4
```

## kube-system pods

```
NAME                                                  READY   STATUS    RESTARTS   AGE
coredns-559f6c778d-2bhxq                              1/1     Running   0          41s
coredns-559f6c778d-gl8m6                              1/1     Running   0          41s
etcd-cloudnova-sre-control-plane                      1/1     Running   0          49s
kindnet-8jnrc                                         1/1     Running   0          41s
kube-apiserver-cloudnova-sre-control-plane            1/1     Running   0          47s
kube-controller-manager-cloudnova-sre-control-plane   1/1     Running   0          50s
kube-proxy-tl7wl                                      1/1     Running   0          41s
kube-scheduler-cloudnova-sre-control-plane            1/1     Running   0          47s
```
