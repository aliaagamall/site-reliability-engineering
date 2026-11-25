# 02 — Observability, Dashboards, and Alerting

**Area:** 4.2 — Observability, Dashboards, and Alerting  
**Status:** Partly implemented. Metrics collection and burn-rate rules are verified (see `evidence/`). The dashboard, other alerts, and alert routing are design only.

## 1. Purpose

This document defines how `shop-api` is monitored, how reliability data is displayed, and how alerts reach the on-call engineer.

SLI and SLO definitions are maintained in document 01.

## 2. Metrics Collection

Prometheus will collect application and Kubernetes metrics.

| Source | Metrics | Purpose |
|---|---|---|
| `shop-api` | Request count, duration, HTTP status | Measure checkout reliability |
| Kubernetes | Pod status, restarts, ready replicas | Monitor workload health |
| Kubelet/cAdvisor | Container CPU and memory | Monitor resource usage |

- Application metrics are exposed through `/metrics`.
- `kube-state-metrics` provides Kubernetes object and Pod state metrics.
- Kubelet/cAdvisor provides container resource metrics.

## 3. Grafana Dashboard

One dashboard, **Service Health**, will display the health of `shop-api`.

The dashboard configuration will be stored in the repository.

| Panel | Purpose | Draft PromQL |
|---|---|---|
| Request rate | Checkout traffic | `sum(rate(http_requests_total{endpoint="/checkout"}[5m]))` |
| Error rate | Share of failed requests | `sum(rate(http_requests_total{endpoint="/checkout",status=~"5..\|408\|429"}[5m])) / sum(rate(http_requests_total{endpoint="/checkout"}[5m]))` |
| Availability | Share of successful requests | `1 - (sum(rate(http_requests_total{endpoint="/checkout",status=~"5..\|408\|429"}[5m])) / sum(rate(http_requests_total{endpoint="/checkout"}[5m])))` |
| p95 latency | 95th percentile request duration | `histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket{endpoint="/checkout"}[5m])))` |
| Requests within 300 ms | Latency SLI | `sum(rate(http_request_duration_seconds_bucket{endpoint="/checkout",le="0.3"}[5m])) / sum(rate(http_request_duration_seconds_count{endpoint="/checkout"}[5m]))` |
| SLO and Error Budget | SLO compliance and remaining budget | Pyrra-generated metrics |
| Pod health | Restarts and ready replicas | Kubernetes metrics; exact queries depend on deployed metric labels |

The error-rate query uses the failure criteria from document 01: HTTP 5xx, 408, and 429.

When there is no checkout traffic, the dashboard must show no data rather than a misleading availability or error-rate value.

### Dashboard Sections

1. **SLO Status:** Availability, latency, and Error Budget.
2. **Application Performance:** Request rate, error rate, and latency.
3. **Kubernetes Health:** Pod status, restarts, and resource usage.

## 4. Alerting

Alerts should represent actionable application or reliability problems.

- Prioritize checkout failures and latency degradation.
- Include dashboard and runbook links.
- Group related alerts to reduce notification noise.
- Use severity levels to control escalation.

### Burn Rate Alerts

Each burn-rate alert uses a long evaluation window and a short confirmation window. Pyrra generates these rules from the SLO definitions in `monitoring/slos/`, so they are not written by hand. The tiers, thresholds, and windows are Pyrra's defaults, verified against the generated rules in `evidence/tests/slo-test.md`.

| Alert tier | Burn Rate | Long Window | Short Window | For | Severity |
|---|---:|---|---|---|---|
| Fast burn | 14x | 1 hour | 5 minutes | 2 minutes | SEV1 |
| Medium burn | 7x | 6 hours | 30 minutes | 15 minutes | SEV2 |
| Slow burn | 2x | 1 day | 2 hours | 1 hour | SEV3 |
| Long-term burn | 1x | 4 days | 6 hours | 3 hours | SEV3 |
| Metric absent | n/a | n/a | n/a | 3 to 10 minutes | SEV2 |

The same tiers apply to the availability and the latency SLO. The metric-absent alert fires when the SLO's metrics disappear, so a missing metric is not mistaken for a healthy service.

Pyrra labels alerts `critical` or `warning` by default. The SLO definitions set the `severity` label explicitly to `sev1`, `sev2`, or `sev3`, so alert routing uses the same names as the incident process.

### Application and Pod Alerts

| Alert | Condition | Severity |
|---|---|---|
| Service down | `shop-api` Prometheus target is unavailable for 2 minutes or disappears | SEV1 |
| Crash looping | A `shop-api` container remains in `CrashLoopBackOff` for 5 minutes | SEV3 |

Exact PromQL expressions and metric labels will be confirmed against the deployed monitoring stack.

## 5. Severity Levels

| Level | Condition | Response |
|---|---|---|
| SEV1 | `shop-api` is unavailable or checkout is failing badly | Page the on-call engineer immediately |
| SEV2 | Checkout is degraded and consuming the Error Budget quickly | Page the on-call engineer |
| SEV3 | Minor issue or early warning | Create a ticket for working-hours follow-up |

These severity levels are also used by the incident process in document 03.

## 6. Alert Routing

```mermaid
flowchart LR
    P[Prometheus] --> AM[Alertmanager]
    AM -->|SEV1 and SEV2| GA[GoAlert]
    AM -->|SEV3| T[Ticket]
    GA --> E[On-call Engineer]
```

### Noise Reduction

| Technique | Purpose |
|---|---|
| Two-window burn rate | Confirms sustained and ongoing problems |
| `for` duration | Prevents alerts from firing on brief spikes |
| Alert grouping | Combines related alerts |
| Inhibition | Suppresses lower-severity alerts when a related SEV1 is active |
| Severity-based routing | Pages only for SEV1 and SEV2 |

The Alertmanager-to-GoAlert integration and SEV3 ticket destination must be tested during implementation.

## 7. Incident Dashboard Workflow

1. Open the dashboard linked in the alert.
2. Check SLO status and Error Budget.
3. Review request rate, error rate, and latency.
4. Check Pod status, restarts, and resource usage.
5. Follow the relevant runbook.

## 8. Open Items

- Verify application metrics and PromQL queries.
- Confirm Kubernetes metrics and labels.
- Verify the dashboard panels and no-traffic behavior.
- Test Alertmanager-to-GoAlert routing.
- Define the SEV3 ticket destination.
- Test alerts using controlled traffic and failure scenarios.
