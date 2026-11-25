# Pyrra

Pyrra turns `ServiceLevelObjective` resources into Prometheus rules and shows SLOs and error budgets in a UI.

## Source

Manifests come from `examples/kubernetes/manifests/` of the upstream repository, tag `v0.10.2` (https://github.com/pyrra-dev/pyrra). The upstream manifests still reference the `v0.9.0` image, so the image is pinned to `v0.10.2` to match the CRD.

## Changes from upstream

| Change | Reason |
|---|---|
| Prometheus URL set to `prometheus.monitoring.svc.cluster.local:9090` | Name of the Prometheus Service in this project |
| Image and version labels set to `0.10.2` | Same version as the CRD |
| Small `resources` on both Deployments | Limited host memory |
| `pyrra-api` Service is a NodePort on `30099` | UI reachable at http://localhost:30099 |
| Pyrra's own ServiceMonitors and the webhook variant (needs cert-manager) are not used | Not needed for this project |

## Layout

| Path | Content |
|---|---|
| `crds/` | The `ServiceLevelObjective` CRD. Applied with `kubectl apply --server-side` because of its size |
| `00-rbac.yaml` | ServiceAccounts, ClusterRole, and ClusterRoleBinding |
| `10-pyrra-kubernetes.yaml` | Controller: turns SLO resources into `PrometheusRule` objects |
| `20-pyrra-api.yaml` | API and UI: shows SLOs and error budgets using Prometheus data |

SLO definitions are added in a later step.
