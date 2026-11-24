# Cluster Test Results

- **Date (UTC):** 2026-11-24 12:06:55
- **kind:** kind version 0.33.0
- **kubectl client:** Client Version: v1.37.2
- **Kubernetes server:** v1.37.0
- **Cluster:** `cloudnova-sre` (one control-plane node)
- **Command:** `tests/cluster-test.sh`
- **Result:** 8 of 8 checks passed

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
| All 7 node ports are published on 127.0.0.1 | 7 | 7 | PASS |

## Nodes

```
NAME                          STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION                              CONTAINER-RUNTIME
cloudnova-sre-control-plane   Ready    control-plane   74s   v1.37.0   172.24.0.2    <none>        Debian GNU/Linux 13 (trixie)   6.18.58.1-microsoft-standard-WSL2 (amd64)   containerd://2.3.4
```

## kube-system pods

```
NAME                                                  READY   STATUS    RESTARTS   AGE
coredns-559f6c778d-6fh5l                              1/1     Running   0          64s
coredns-559f6c778d-zx9v6                              1/1     Running   0          64s
etcd-cloudnova-sre-control-plane                      1/1     Running   0          70s
kindnet-bfthh                                         1/1     Running   0          64s
kube-apiserver-cloudnova-sre-control-plane            1/1     Running   0          72s
kube-controller-manager-cloudnova-sre-control-plane   1/1     Running   0          70s
kube-proxy-qs86s                                      1/1     Running   0          64s
kube-scheduler-cloudnova-sre-control-plane            1/1     Running   0          71s
```
