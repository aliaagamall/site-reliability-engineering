# Service Health Metrics and Reliability Targets

## 1. Overview

Reliable systems require more than simply keeping services running. SRE teams need measurable indicators to understand service health and clear reliability targets to evaluate whether a service is performing as expected.

This part introduces two fundamental SRE concepts:

- **Service Level Indicators (SLIs):** Measurements used to evaluate actual service performance.
- **Service Level Objectives (SLOs):** Reliability targets that define the expected level of service performance.

It also explores Error Budgets and Budget Policies, which help teams balance software delivery speed with service reliability.

## 2. Service Level Indicators (SLIs)

A Service Level Indicator (SLI) is a quantitative measurement that indicates how well a service is performing from the user's perspective.

SLIs help teams replace assumptions about reliability with measurable information about actual service behavior.

### 2.1 Common SLIs

| SLI | Description | User Impact |
|---|---|---|
| Availability | Measures whether the service is reachable and working. | Users can access the service. |
| Latency | Measures how long requests take to complete. | Users experience fast or slow responses. |
| Error Rate | Measures how frequently requests fail. | Users experience failed actions or transactions. |
| Request Success Rate | Measures the proportion of successfully completed requests. | Users can complete their intended operations. |
| Throughput | Measures how much traffic or work a service can handle. | Reflects the service's ability to handle demand. |

### 2.2 SLIs and User Experience

Good SLIs should reflect what users actually experience rather than focusing only on internal infrastructure health.

For example:

- High availability helps users access the service consistently.
- Low latency provides faster responses.
- A high error rate results in failed actions and incomplete transactions.
- Poor request success rates indicate that users cannot reliably complete their tasks.

A system may appear healthy internally while users are experiencing slow responses or failed requests.

**Key Principle:** SLIs connect measurable system behavior with actual user experience.

## 3. Service Level Objectives (SLOs)

A Service Level Objective (SLO) defines the target level of reliability that a service is expected to achieve.

While an SLI measures actual service performance, an SLO establishes the desired performance target.

### 3.1 SLO Examples

**Example 1: Availability Target**

A service should maintain 99.9% availability over a specified measurement period.

**Example 2: Latency Target**

Most service requests should complete in less than 300 milliseconds.

These targets establish clear expectations and make reliability measurable instead of subjective.

### 3.2 SLIs vs SLOs

| Aspect | SLI | SLO |
|---|---|---|
| Meaning | Service Level Indicator | Service Level Objective |
| Purpose | Measures actual performance. | Defines expected performance. |
| Focus | What is happening? | What should happen? |
| Nature | Measurement | Target |
| Example | Actual availability is 99.95%. | Target availability is 99.9%. |

**Simple Explanation:**

- SLI tells us how the service is performing.
- SLO tells us how well the service is expected to perform.

### 3.3 SLOs and Operational Decisions

SLOs help teams decide where to focus engineering effort.

When a service meets its SLOs:

- Teams may continue developing and releasing new features.
- Reliability is performing within the expected target.

When a service misses its SLOs:

- Teams may prioritize reliability improvements.
- Performance problems may need investigation.
- Incident reduction may become a priority.

SLOs provide measurable criteria for making operational decisions.

## 4. SLIs, SLOs, and User Experience

SLIs are most valuable when they represent the actual experience of service users.

Consider an application that is technically running but frequently returns failed requests.

Infrastructure monitoring alone may not reveal the full impact, but user-facing indicators can expose the problem.

| Service Behavior | User Experience |
|---|---|
| High availability | Consistent service access. |
| Low latency | Fast and responsive interactions. |
| High latency | Slow and frustrating interactions. |
| High error rate | Failed actions and broken functionality. |
| High success rate | More reliable completion of user operations. |

Good reliability measurements should reflect the service outcomes that matter to users.

## 5. Why SLIs and SLOs Matter

SLIs and SLOs support data-driven operational decisions.

### 5.1 Performance Decisions

Teams can identify:

- Slow services.
- Capacity issues.
- Performance degradation.
- Reliability gaps.

These decisions are based on measurable service behavior rather than assumptions.

### 5.2 Incident Decisions

When a service is missing its SLOs, teams can:

- Prioritize incident response.
- Understand the reliability impact.
- Communicate service issues more clearly.

### 5.3 Engineering Improvements

SLIs and SLOs help teams identify where engineering effort is most valuable.

Instead of making improvements based on assumptions, teams can focus on measurable reliability risks.

## 6. Error Budgets

An Error Budget represents the amount of unreliability a service can tolerate while still meeting its SLO.

No system can guarantee perfect reliability all the time. Error budgets acknowledge that some failures may happen while establishing an acceptable reliability limit.

These failures may appear as:

- Service downtime.
- Failed requests.
- Slow responses.
- Performance degradation.

Each reliability issue consumes part of the available error budget.

### 6.1 Error Budget Example

Consider a service with an availability SLO of 99.9%.

The remaining 0.1% represents its error budget.

```text
SLO:          99.9%
Error Budget:  0.1%
```

This means the service is allowed a small amount of unreliability while remaining within its defined reliability target.

The error budget provides a measurable allowance for reliability risk.

### 6.2 Error Budget Consumption

The error budget is consumed when reliability issues occur.

Examples include:

- Outages affecting service availability.
- Failed user requests.
- Slow responses and degraded performance.

As these issues accumulate, the remaining error budget decreases.

A healthy remaining budget indicates that the team still has room to introduce changes while maintaining its reliability target.

A nearly exhausted budget indicates that reliability is at risk.

## 7. Error Budgets and Release Decisions

Error budgets help SRE teams balance two important goals:

- Delivering new features and improvements.
- Protecting service reliability.

They provide measurable information to guide release decisions.

### 7.1 When the Error Budget Is Healthy

When the service is operating within its reliability target:

- Teams have room to release new features.
- Product improvements can continue.
- Engineering teams can move forward with greater confidence.

### 7.2 When the Error Budget Is Nearly Exhausted

When most of the available error budget has been consumed:

- Teams should slow down risky changes.
- Reliability issues should receive higher priority.
- Existing incidents should be addressed.
- Performance should be improved.
- Monitoring may need strengthening.

The objective is to stabilize the service before introducing additional risk.

### 7.3 Release Decision Summary

| Error Budget Condition | Recommended Focus |
|---|---|
| Healthy | Continue innovation and feature releases. |
| Nearly exhausted | Slow down releases and stabilize the service. |

**Key Principle:** Release decisions should be guided by reliability data rather than assumptions.

## 8. Error Budget Policies

An Error Budget Policy is a shared agreement that defines how teams should make decisions based on the remaining error budget.

Without a defined policy, release decisions may become unclear.

For example:

- Product teams may want to release features faster.
- Operations teams may want to prioritize system stability.

An error budget policy provides a common decision-making framework.

### 8.1 Purpose of Budget Policies

Budget policies help teams:

- Establish clear release expectations.
- Balance delivery speed and reliability.
- Agree on actions when reliability decreases.
- Prioritize reliability improvements when necessary.
- Avoid unclear or conflicting release decisions.

### 8.2 How Budget Policies Guide Teams

**When the budget is available:**

Teams can continue delivering new value while maintaining reliability.

**When the budget is low:**

Teams should focus more on stabilizing the service and reducing reliability risks.

The policy does not aim to stop innovation. It ensures that innovation does not continuously compromise service reliability.

## 9. Relationship Between SLIs, SLOs, and Error Budgets

These three concepts work together as part of a reliability management process.

```text
        SLIs
         |
         v
 Measure Actual Service Health
         |
         v
        SLOs
         |
         v
 Compare Performance Against Target
         |
         v
    Error Budget
         |
         v
 Evaluate Remaining Reliability Allowance
         |
         v
   Release Decisions
         |
         v
 Innovation or Reliability Improvements
```

- **SLI:** Measures actual service performance.
- **SLO:** Defines the expected reliability target.
- **Error Budget:** Represents the acceptable unreliability.
- **Budget Policy:** Guides decisions based on the remaining budget.

Together, these concepts help teams manage reliability through measurable outcomes.

## 10. Key Takeaways

- SLIs measure actual service performance from the user's perspective.
- SLOs define the expected level of service reliability.
- Common SLIs include availability, latency, error rate, request success rate, and throughput.
- SLOs support measurable reliability goals and operational decisions.
- Error budgets represent the acceptable amount of unreliability.
- A 99.9% availability SLO corresponds to a 0.1% error budget.
- Reliability issues consume the available error budget.
- Healthy budgets allow teams more room to release improvements.
- Nearly exhausted budgets signal the need to prioritize stability.
- Error budget policies establish shared agreements for release decisions.
- The goal is to balance innovation with sustainable service reliability.
