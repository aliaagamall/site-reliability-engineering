# 01 — Reliability Measurement and SLO Strategy

**Area:** 4.1 — Reliability Measurement  
**Status:** Design only

## 1. Purpose

This document defines the reliability measurements and targets for `shop-api`, including SLIs, SLOs, Error Budgets, and release policies.

The project scope and application architecture are defined in document 00.

## 2. Critical User Journey

The reliability measurement focuses on:

`POST /checkout`

The `/health` and `/metrics` endpoints are excluded from user-facing SLIs.

## 3. Service Level Indicators (SLIs)

| SLI | Good Event | Total Events |
|---|---|---|
| Request Success Rate | HTTP status is not 408, 429, or 5xx | All observed checkout requests |
| Latency | Request duration is 300 ms or less | All observed checkout requests |

### Measurement Rules

- HTTP 5xx, 408, and 429 responses count as failures.
- Other 4xx responses count as successful events for the availability SLI.
- Error Rate = `1 - Success Rate`.
- Availability is request-based, not time-based.
- Measurements include only requests observed by the application.

### Required Application Metrics

| Metric | Type | Labels | Purpose |
|---|---|---|---|
| `http_requests_total` | Counter | endpoint, status | Request count and success rate |
| `http_request_duration_seconds` | Histogram | endpoint | Request latency |

The histogram must include a bucket boundary at `0.3` seconds.

The `endpoint` label must use normalized routes such as `/checkout`, not full URLs or dynamic IDs.

## 4. Service Level Objectives (SLOs)

Both SLOs use a rolling 28-day window.

| SLO | Target |
|---|---|
| Availability | 99.9% of checkout requests meet the success criteria |
| Latency | 99% of checkout requests complete within 300 ms |

These are initial targets. They will be reviewed after collecting traffic and validating the application metrics.

## 5. Error Budgets

| SLO | Allowed Failure |
|---|---|
| Availability 99.9% | 0.1% of checkout requests |
| Latency 99% | 1% of checkout requests |

For 1,000,000 checkout requests:

- Availability budget: 1,000 failed requests.
- Latency budget: 10,000 requests exceeding 300 ms.

### Burn Rate

`Burn Rate = Observed Error Rate / Allowed Error Rate`

For the availability SLO:

| Observed Error Rate | Burn Rate |
|---|---|
| 0.1% | 1x |
| 0.6% | 6x |
| 1.44% | 14.4x |

Alert thresholds and evaluation windows are defined in document 02.

## 6. Error Budget Policy

| Remaining Budget | Release Policy |
|---|---|
| More than 50% | Normal release process |
| 25%–50% | Releases require a verified rollback plan |
| Less than 25% | Prioritize reliability work; SRE approval required for risky changes |
| Exhausted | Pause feature releases and focus on reliability fixes |
| Fast-burn alert active | Pause non-emergency deployments while investigating |

Security fixes and necessary rollbacks remain allowed.

These policies will be reviewed as part of governance (Area 4.6).

## 7. SLO Tracking

Pyrra will manage and track the SLOs through Prometheus.

The implementation will include:

- Version-controlled SLO definitions.
- SLI performance and Error Budget tracking.
- Generated Prometheus recording and alerting rules.

The configuration and generated rules must be verified before this capability is marked implemented.

## 8. Open Items

- Confirm metric names and labels during application implementation.
- Validate the success-rate calculation against actual HTTP responses.
- Verify the 300 ms histogram bucket.
- Validate Pyrra configuration and generated rules.
- Review the initial targets after the first week of traffic to check instrumentation and target suitability.
