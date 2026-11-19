
# 01 — Reliability Measurement and SLO Strategy

**Area:** 4.1 — Reliability Measurement  
**Status:** Design only

## 1. Purpose

CloudNova needs a clear way to measure service reliability instead of relying on assumptions such as "the service is slow" or "the application is stable."

This document defines:
- What we measure (SLIs).
- What reliability targets we set (SLOs).
- How much failure we can accept (Error Budgets).
- How reliability measurements influence release decisions.

The definitions will be validated when the application and monitoring stack are implemented.

## 2. Core Concepts

| Term | Meaning |
|---|---|
| Reliability | The service consistently works as expected |
| Availability | The percentage of user requests that succeed |
| Resilience | The ability to recover from failures |
| SLI | A measurement of service reliability |
| SLO | A target for an SLI over a defined period |
| Error Budget | The amount of failure allowed by an SLO |

## 3. Critical User Journey

The project will run one application in Kubernetes: `shop-api`.

Its critical user journey is the checkout operation, exposed through:

`POST /checkout`

This operation represents a business-critical customer action, so its reliability is the main focus of this project.

The following endpoints are excluded from user-facing reliability measurements:

- `/health`: used for health checks.
- `/metrics`: used to expose monitoring data.

## 4. Service Level Indicators (SLIs)

Two SLIs will measure the checkout experience.

| SLI | Definition | Good Event | Total Events |
|---|---|---|---|
| Request Success Rate | Percentage of successful checkout requests | HTTP status is not 408, 429, or 5xx | All observed checkout requests |
| Latency | Percentage of checkout requests completed within 300 ms | Request duration is 300 ms or less | All observed checkout requests |

### Measurement Rules

- HTTP 5xx responses count as failures.
- HTTP 408 and 429 responses also count as failures because they indicate a timeout or rate-limiting impact on the customer.
- Other 4xx responses count as good events because they generally represent invalid client input rather than service failures.
- Error rate is derived from the success rate:

  `Error Rate = 1 - Success Rate`

- Availability is request-based. It measures actual checkout requests rather than uptime checks.

These measurements represent requests observed by the application. Failures that happen before a request reaches the application may not appear in its metrics.

### Required Application Metrics

The application will expose the following Prometheus metrics:

| Metric | Type | Labels | Purpose |
|---|---|---|---|
| `http_requests_total` | Counter | endpoint, status | Request count and success rate |
| `http_request_duration_seconds` | Histogram | endpoint | Request latency |

The histogram will include a bucket boundary at `0.3` seconds to support the latency SLI.

The `endpoint` label will use a normalized route such as `/checkout`, not a full URL or a path containing dynamic IDs.

## 5. Service Level Objectives (SLOs)

Both SLOs use a rolling 28-day window.

| SLO | Target | Meaning |
|---|---|---|
| Availability | 99.9% | At least 99.9% of checkout requests meet the success criteria |
| Latency | 99% within 300 ms | At least 99% of checkout requests complete within 300 ms |

### Target Rationale

- **99.9% Availability:** A reasonable starting target for a business-critical operation.
- **99% Latency:** Allows a small percentage of slower requests without making the target unnecessarily strict.
- **28-day Window:** Provides a consistent period for reviewing reliability trends and release decisions.

These are initial targets and may be adjusted after collecting traffic and reviewing the results.

### Other Example Services (Design Only)

The same SLO approach could be applied to other services in a larger CloudNova environment.

These are design examples, not additional applications deployed in this project.

| Service | Availability | Latency |
|---|---|---|
| Frontend application | 99.9% | 99% within 500 ms |
| Backend API | 99.9% | 99% within 300 ms |
| Database-connected service | 99.5% | 99% within 500 ms |
| Checkout service (`shop-api`) | 99.9% | 99% within 300 ms |
| Internal platform service | 99.0% | 95% within 1 second |

Only `shop-api` will be implemented and measured in the cluster.

## 6. Error Budgets

An Error Budget represents the amount of failure allowed while still meeting an SLO.

| SLO | Allowed Failure |
|---|---|
| Availability 99.9% | 0.1% of checkout requests |
| Latency 99% | 1% of checkout requests |

For example, with 1,000,000 checkout requests:

- The availability budget allows 1,000 failed requests.
- The latency budget allows 10,000 requests exceeding 300 ms.

### Error Budget Burn Rate

Burn rate shows how quickly the service consumes its allowed error budget.

`Burn Rate = Observed Error Rate / Allowed Error Rate`

For the 99.9% availability SLO:

| Observed Error Rate | Burn Rate |
|---|---|
| 0.1% | 1x |
| 0.6% | 6x |
| 1.44% | 14.4x |

A higher burn rate means the service is consuming its error budget faster than expected.

Detailed alert thresholds and evaluation windows will be defined in the Observability document (Area 4.2).

## 7. Error Budget Policy

The remaining Error Budget guides release decisions.

| Budget Status | Release Policy |
|---|---|
| More than 50% remaining | Normal release process |
| 25%–50% remaining | Releases continue with a verified rollback plan |
| Less than 25% remaining | Prioritize reliability improvements and require SRE approval for risky changes |
| Exhausted | Pause feature releases and focus on reliability fixes |
| Fast-burn alert active | Pause non-emergency deployments while investigating the incident |

Security fixes and necessary rollbacks remain allowed.

These policies are initial proposals and will be reviewed as part of the governance process (Area 4.6).

## 8. SLO Tracking with Pyrra

Pyrra will be used to manage and track SLOs through Prometheus.

It is expected to support:

- Defining SLOs as version-controlled configuration.
- Tracking SLI performance against SLO targets.
- Monitoring remaining Error Budgets.
- Generating Prometheus recording and alerting rules.

The exact configuration format and generated rules will be verified during the monitoring implementation phase.

**Status remains Design only** until the configuration is deployed and validated.

## 9. Reliability Improvement

| Before | After |
|---|---|
| "Checkout is slow" | A measurable latency target |
| "The service is unreliable" | A defined success-rate objective |
| "We should stop releasing" | Release decisions based on the Error Budget |
| "The alert looks serious" | Burn rate helps assess reliability impact |

## 10. Open Items

- Confirm metric names and labels during application implementation.
- Validate the success-rate calculation against actual HTTP responses.
- Verify the 300 ms histogram bucket and latency calculation.
- Validate the Pyrra configuration and generated Prometheus rules.
- Review the initial SLO targets after collecting the first week of traffic. This first review checks instrumentation and target suitability; it does not replace the full 28-day SLO window.
