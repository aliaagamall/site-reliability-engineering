# Local Cluster

A single-node `kind` cluster named `cloudnova-sre`.

```bash
cluster/create.sh    # create the cluster (skips if it exists)
cluster/delete.sh    # delete it and everything in it
```

## Local Access Ports

Node ports are published on `127.0.0.1` only, so services are reachable from the host without `kubectl port-forward`.

| Port | Service | Phase | Status |
|---|---|---|---|
| 30080 | shop-api | App | Used |
| 30300 | Grafana | Monitoring | Reserved |
| 30900 | Prometheus | Monitoring | Reserved |
| 30093 | Alertmanager | Monitoring | Reserved |
| 30099 | Pyrra | Monitoring | Reserved |
| 30081 | GoAlert | On-call | Reserved |
| 30443 | Argo CD | GitOps | Reserved |

Port mappings can only be set when the cluster is created. Adding a port later means deleting and recreating the cluster, which is why all planned ports are reserved now.
