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

## 3. Turning Monitoring Data into Reliability

Monitoring systems generate large amounts of data, but data alone does not improve reliability.

SRE teams need dashboards and alerts that help them understand service health, detect problems early, and respond with the appropriate level of urgency.

Dashboards, alerts, and SLO monitoring should support clear operational decisions rather than simply displaying metrics or sending notifications.

### Why Dashboards Need a Clear Purpose

Dashboards should be designed around specific operational questions instead of displaying every available metric.

An effective SRE dashboard should help answer:

- Is the service available?
- Are users experiencing errors?
- Is latency increasing?
- Is the service meeting its SLO?
- Is the error budget being consumed too quickly?

Useful dashboard metrics include:

- Request rate.
- Latency.
- Error rate.
- Availability.
- SLO compliance.

These signals help engineers identify whether a service is healthy or degraded.

### Connecting Alerts to User Impact

Alerts should notify teams when action is needed, not whenever a metric changes.

Excessively sensitive alerts create unnecessary notifications and eventually lead to alert fatigue.

Strong alerts are connected to user impact.

For example:

- An alert based on a high error rate can indicate that users are experiencing failed requests.
- An alert based on a high SLO burn rate can indicate that the service is consuming its error budget too quickly.
- A temporary CPU increase does not necessarily mean users are experiencing a problem.

Infrastructure alerts can still be useful, but their priority should reflect their impact on service reliability.

Good alerts should explain:

1. **What is wrong?**
2. **Why does it matter?**
3. **What should the responder check first?**

They should also be routed to the correct responsible team.

### Using SLO Monitoring for Better Decisions

SLO monitoring moves beyond simple up-or-down monitoring.

Instead of checking only whether a service is running, teams measure whether it meets an agreed reliability target.

A service can be available but still violate its latency SLO if users receive very slow responses.

SLO monitoring helps teams identify degraded user experiences and make better decisions about:

- Release speed.
- Incident response.
- Reliability improvements.
- Engineering priorities.

When an SLO dashboard shows that the error budget is being consumed quickly, teams may:

- Slow down deployments.
- Investigate recurring incidents.
- Prioritize stability improvements.

This makes monitoring part of engineering decision-making, not just system observation.

### Keeping Monitoring Practical

Monitoring systems should be reviewed regularly because applications and user journeys change over time.

To keep monitoring useful:

- Remove unused dashboard panels.
- Tune noisy alerts.
- Update dashboards when application behavior changes.
- Review whether existing metrics are still relevant.
- Add new SLO views when important user journeys require them.
- Document the purpose of important dashboards and alerts.

A metric that was useful during early development may become less important in production, while new application behavior may require additional monitoring.

### From Monitoring Data to Reliability Action

The main roles of the monitoring components are complementary:

| Component | Purpose |
|---|---|
| **Dashboards** | Provide visibility into service health and performance. |
| **Alerts** | Notify teams when action is required. |
| **SLO Monitoring** | Connect system behavior to reliability objectives. |
| **Error Budgets** | Help guide release and reliability decisions. |

The most effective monitoring setup is simple, user-focused, and actionable.

By designing dashboards and alerts around real operational decisions, SRE teams can reduce noise, respond faster, and manage reliability with greater confidence.

---

## 4. Key Takeaways

- Effective dashboards provide fast insight and support operational decisions.
- The Four Golden Signals are Latency, Traffic, Errors, and Saturation.
- Service Health Panels show the current service state, while SLO Views track reliability over time.
- Actionable alerts require attention, identify real problems, and provide a response path.
- Symptom-based alerting focuses on user impact.
- Correct alert routing helps the responsible team respond faster.
- Reducing alert noise improves engineers' trust in the alerting system.
- Monitoring data becomes valuable when it leads to practical reliability actions.
- SLO monitoring helps teams make informed decisions about deployments and reliability improvements.
- Dashboards, alerts, and error budgets should be reviewed regularly to remain useful as systems evolve.