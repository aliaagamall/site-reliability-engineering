# Part 02: Dashboards and Alerting

## 1. Building Effective SRE Dashboards

An effective SRE dashboard provides a clear view of service health and helps engineers make decisions quickly.

A dashboard should focus on relevant information rather than displaying as many metrics as possible.

### Qualities of an Effective Dashboard

1. **Fast Insight:** Engineers should understand the current service health within seconds.
2. **Decision-Driven:** Every panel should answer an operational question and support a decision.
3. **Signal Over Noise:** Important signals should be easy to identify without unnecessary information.

### The Four Golden Signals

The Four Golden Signals are essential indicators for understanding service behavior.

| Signal | Description | Examples |
|---|---|---|
| **Latency** | Time required to serve a request. | Request response time and slow requests. |
| **Traffic** | Amount of demand placed on the service. | Requests per second. |
| **Errors** | Rate of requests that fail. | HTTP 500 responses and incorrect results. |
| **Saturation** | How close the service is to its resource limits. | CPU, memory, disk, and connection utilization. |

**Important:** Successful and failed requests should have their latency tracked separately because failed requests may behave differently from successful ones.

### Dashboard Views

SRE dashboards can provide two complementary views:

#### Service Health Panels

These panels answer:

**Is the service working correctly right now?**

They provide visibility into the current service state and help engineers identify problems quickly.

#### SLO Views

These panels answer:

**Is the service meeting its reliability objectives over time?**

They help teams monitor:

- Actual performance compared with SLO targets.
- Reliability trends over time.
- User experience risks.
- Error budget consumption and burn.

### Avoiding Dashboard Clutter

A dashboard should not contain charts simply because metrics are available.

- Every panel should have a clear purpose.
- Each panel should answer a specific operational question.
- Remove information that does not support a decision.
- Keep important signals easy to identify.

Too many charts can slow down troubleshooting and decision-making during incidents.

---

## 2. Alerting Principles and Reducing Alert Fatigue

Alerts notify engineers about service problems that require attention.

An effective alerting system reduces guesswork during incidents and helps engineers understand when and how to respond.

### Qualities of an Actionable Alert

An actionable alert should have three qualities:

1. **Requires Human Attention:** It should indicate a situation that needs human intervention. If automation can resolve the issue without human involvement, paging an engineer may be unnecessary.
2. **Indicates a Real Problem:** It should clearly identify an actual service problem rather than a vague internal condition.
3. **Provides a Response Path:** It should include enough context to help engineers understand the affected service, possible cause, and appropriate response.

An alert without a clear response path creates noise instead of helping engineers.

### Alert Severity

Severity communicates how urgently an alert needs attention.

- **Critical:** Requires immediate action because the service is down or the user experience is significantly degraded.
- Not every alert should wake up an on-call engineer.
- Alert urgency should reflect the actual impact of the problem.

### Symptom-Based Alerting

Alerts should focus primarily on user-facing symptoms rather than isolated internal resource metrics.

Examples of user-facing symptoms:

- Increased response latency.
- Failed requests.
- Elevated error rates.

Internal metrics such as high CPU or memory utilization are useful for investigation and troubleshooting. However, they are not always suitable as primary alert triggers when there is no demonstrated user impact.

### Alert Routing

Alerts should reach the team responsible for the affected service or component.

Routing can be organized by:

- Service component.
- Region.
- Environment.
- Responsible team or service owner.

Correct routing reduces unnecessary handoffs and helps the responsible engineers respond faster.

### Understanding Alert Fatigue

Alert fatigue happens when engineers receive too many low-value, duplicate, or irrelevant alerts.

Over time:

- Engineers may stop trusting alerts.
- Important notifications can be overlooked.
- On-call engineers may ignore alerts because many of them do not require action.

### Reducing Alert Fatigue

To improve alert quality:

1. Remove duplicate and low-value alerts.
2. Delete or demote alerts that repeatedly fire without leading to useful action.
3. Review thresholds using historical service behavior.
4. Avoid relying on arbitrary default thresholds.
5. Keep alerts focused on meaningful service problems.

**The goal is not to generate more alerts. The goal is to generate fewer, more useful, and more trustworthy alerts.**

---

## 3. Key Takeaways

- Effective dashboards provide fast insight and support operational decisions.
- The Four Golden Signals are Latency, Traffic, Errors, and Saturation.
- Service Health Panels show the current service state, while SLO Views track reliability over time.
- Actionable alerts require attention, identify real problems, and provide a response path.
- Symptom-based alerting focuses on user impact.
- Correct alert routing helps the responsible team respond faster.
- Reducing alert noise improves engineers' trust in the alerting system.