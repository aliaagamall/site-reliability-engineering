# Part 03: Incident Management and On-Call Practices

## 1. Managing Incidents for Reliable Services

### What Is Incident Management?

Incident management is the process of detecting, coordinating, responding to, and resolving incidents that affect service reliability.

Its main goals are to:

- Restore normal service operation as quickly as possible.
- Minimize user impact.
- Coordinate response activities.
- Prevent similar incidents from recurring.

Incidents may involve service outages, performance degradation, failed deployments, infrastructure problems, or unexpected user impact.

The objective is not to eliminate every possible failure, but to prepare teams to respond effectively when failures occur.

### The Incident Lifecycle

Incident management follows a structured lifecycle.

#### 1. Detection

An incident can be detected through:

- Monitoring alerts.
- Dashboards.
- Application logs.
- Distributed traces.
- User reports.

Effective detection helps teams identify reliability problems before they cause greater user impact.

#### 2. Triage and Severity Classification

After detection, the team evaluates the incident to understand its scope and urgency.

Triage considers:

- Number of affected users.
- Affected services or components.
- Technical impact.
- Business impact.
- Current service reliability.

Severity classification determines response urgency, required responders, and communication expectations.

#### 3. Escalation and Communication

The incident should be assigned to the appropriate responder or team.

Escalation is necessary when:

- The current responder cannot resolve the issue.
- The incident affects additional users or services.
- The impact or risk increases.
- The service approaches an SLO violation.
- Additional expertise is required.

Incident updates should communicate the current situation, user impact, actions being taken, and the next update when appropriate.

#### 4. Mitigation and Resolution

The immediate priority is to reduce user impact and restore service.

Possible mitigation actions include:

- Rolling back a problematic deployment.
- Restarting an affected service.
- Redirecting traffic.
- Disabling a risky feature.

Mitigation may restore service before the team fully understands the root cause.

After recovery, the team should verify that the service is stable, metrics have returned to normal, and users are no longer affected.

#### 5. Follow-Up and Improvement

After resolving the incident, the team should document what happened and identify improvements.

Follow-up work may include:

- Fixing software defects.
- Improving monitoring and alerting.
- Updating runbooks.
- Adding deployment checks.
- Improving system resilience.

Incident management should lead to continuous improvement, not just service restoration.

## 2. Blameless Postmortems

### What Is an Incident Postmortem?

An incident postmortem is a structured report created after an incident to document what happened, how the team responded, and what can be improved.

A useful postmortem captures:

- Incident impact.
- Timeline of events.
- Root cause and contributing factors.
- Response actions.
- Lessons learned.
- Corrective actions.

### Blameless Culture

A blameless postmortem focuses on system behavior, technical conditions, and process improvements rather than assigning personal blame.

Instead of asking:

"Who made the mistake?"

Ask:

"What conditions allowed this failure to happen, and how can we improve the system?"

A blameless approach encourages people to share accurate information, identify contributing factors, and improve reliability.

It does not mean avoiding accountability. It means focusing accountability on improving systems and processes instead of blaming individuals.

### Postmortem Process

#### 1. Build the Incident Timeline

Record important events in chronological order:

- When the incident started.
- When monitoring detected the issue.
- When the alert was received.
- When investigation began.
- When the cause was identified.
- Which mitigation actions were performed.
- When service was restored.

The timeline helps teams understand detection and recovery performance.

#### 2. Identify Contributing Factors

Investigate the conditions that allowed the incident to happen or increased its impact.

Examples include:

- Missing monitoring alerts.
- Unclear service ownership.
- Risky configuration changes.
- Insufficient system capacity.
- Communication gaps.

Distinguish confirmed causes from assumptions that require further investigation.

#### 3. Define Corrective Actions

Turn findings into specific improvement tasks.

Examples:

- Add missing monitoring metrics.
- Improve alert descriptions.
- Create or update runbooks.
- Add automated checks.
- Improve deployment procedures.
- Perform load testing.

Each action should have a responsible owner and a target completion date.

#### 4. Review and Track Improvements

Postmortem actions should be reviewed until completion.

The team should verify whether the improvements actually reduce the likelihood or impact of similar incidents.

### Postmortem Outcomes

A useful postmortem should provide:

- A clear understanding of incident impact.
- A documented timeline.
- Root cause and contributing factors.
- Assigned corrective actions.
- Owners and due dates.
- Follow-up reviews until actions are completed.

Without follow-up, postmortems become documentation rather than a mechanism for improving reliability.

## 3. On-Call Best Practices

### What Is On-Call?

On-call is an operational responsibility in which designated team members are available to respond to incidents outside or during their normal working hours, according to an agreed schedule.

The purpose is to ensure that important alerts reach someone responsible for responding.

### Clear Ownership

Every alert should have a clear owner.

Responders should understand the difference between:

- **Monitor:** Observe the situation and collect information.
- **Acknowledge:** Confirm that the alert has been received and someone is taking ownership.
- **Act:** Investigate the issue and perform the necessary response actions.

Acknowledgment does not mean the incident has been resolved.

### Minimize User Impact

During an incident, responders should prioritize reducing user impact.

Temporary mitigation may be more important than immediately finding a permanent fix.

Examples include:

- Rolling back a deployment.
- Restarting an unhealthy service.
- Disabling a problematic feature.
- Redirecting traffic away from an affected component.

Important decisions and response actions should remain visible to the team.

### Use Runbooks

A runbook is documented operational guidance that helps responders investigate and handle known problems.

A useful runbook may contain:

- Symptoms and possible causes.
- Systems and dashboards to inspect.
- Relevant logs and metrics.
- Diagnostic commands.
- Recovery procedures.
- Escalation contacts.

Runbooks reduce investigation time and help responders follow consistent procedures.

### Actionable Alerts

An alert should:

- Indicate a meaningful problem.
- Require human attention when necessary.
- Identify the affected service or component.
- Provide useful diagnostic context.
- Point to the appropriate owner or runbook.

Alerts that do not require action should not unnecessarily interrupt responders.

## 4. Building Sustainable On-Call Coverage

### Primary and Backup Responders

A healthy on-call structure should define:

- **Primary Responder:** The first person responsible for receiving and handling alerts.
- **Backup Responder:** The next escalation contact when the primary responder is unavailable or does not acknowledge an alert.
- **Handoff:** The transfer of operational responsibility between responders.

This structure prevents critical incidents from depending on a single person.

### On-Call Rotations

On-call schedules should distribute responsibility fairly.

Consider:

- Different time zones.
- Responder experience.
- Recent incident workload.
- Availability and rest periods.

A sustainable rotation helps prevent operational responsibilities from becoming concentrated on a small number of people.

### Effective Handoffs

A planned handoff should communicate:

- Active incidents.
- Ongoing investigations.
- Important service issues.
- Current risks.
- Items that require monitoring.

The incoming responder should understand the current operational situation before taking responsibility.

### Reviewing Rotation Health

Teams should periodically review:

- Alert volume.
- Incident frequency.
- Backup responder usage.
- Responder workload.
- Rest and recovery time.
- Repeated incidents during specific shifts.

On-call practices should protect both service reliability and team well-being.

## 5. Escalation Workflows

### What Is Escalation?

Escalation is the process of transferring an incident or alert to another responder or team when additional attention or expertise is required.

It helps ensure that incidents receive an appropriate response even when the initial responder cannot handle them.

### When Should Escalation Happen?

Escalate when:

- The primary responder does not acknowledge an alert within the configured time.
- The incident impact increases.
- Additional users or services become affected.
- The service approaches an SLO violation.
- The current responder lacks the required expertise.
- The issue requires another team's involvement.

Escalation should happen early enough to avoid unnecessary delays.

### Escalation Context

A useful escalation should include:

- Incident symptoms.
- Affected services and users.
- Actions already performed.
- Current incident status.
- Relevant investigation findings.
- Required assistance.

The escalation should reach the team or person capable of resolving the issue.

### Communication During Escalation

Incident updates should be concise, accurate, and time-stamped.

Responders should communicate:

- What is happening.
- Who is affected.
- What actions are being taken.
- Whether additional support is required.

Clear communication keeps responders aligned throughout the incident lifecycle.

## 6. Managing On-Call Workload

On-call work can become stressful when alerts are noisy, responsibilities are unclear, or escalation procedures are ineffective.

Teams should regularly improve the operational process.

### Reduce Alert Noise

- Review alert rules regularly.
- Remove duplicate or unnecessary alerts.
- Tune noisy thresholds using historical behavior.
- Avoid paging responders for issues that do not require immediate action.

An alert that never leads to an action should be reviewed.

### Improve Operational Documentation

Repeated incidents should lead to better documentation and recovery procedures.

Improve runbooks when responders repeatedly encounter the same investigation steps or operational difficulties.

### Protect Responder Well-Being

Healthy on-call practices include:

- Fair distribution of shifts.
- Access to backup responders.
- Recovery time after intense incidents.
- Reviewing repeated incident patterns.
- Blameless incident retrospectives.

The goal is to maintain reliable services without creating unsustainable operational pressure.

## 7. Building Incident Readiness

### What Is Incident Readiness?

Incident readiness means preparing teams and processes before an incident occurs.

Teams should not wait until an outage happens to decide who is responsible, how to communicate, or which recovery steps to follow.

Effective incident readiness includes:

- **Defined Responsibilities:** Clear ownership of services and incident response roles.
- **Escalation Paths:** Established procedures for contacting the appropriate responders and teams.
- **Runbooks:** Documented recovery procedures and troubleshooting steps.
- **Service Ownership:** Clear information about which team is responsible for each service.
- **Communication Channels:** Agreed channels for sharing incident updates and coordinating response.
- **Severity Definitions:** Classification criteria that help determine incident urgency, response priority, and required involvement.

Preparation helps teams respond faster because responsibilities and response procedures are already established.

## 8. Communication During Incidents

Communication is an essential part of incident response, alongside technical investigation and recovery.

Different audiences need different information:

- **Engineers:** Technical symptoms, investigation findings, affected components, and recovery actions.
- **Managers:** User impact, incident severity, response progress, and expected next steps.
- **Users and Customers:** Service impact, current status, and relevant updates.

Clear incident updates should answer three questions:

1. What is happening?
2. Who is affected?
3. What action is being taken?

Updates should be brief, accurate, and shared regularly.

The root cause does not need to be fully identified before communicating. Teams can share what is currently known, what is being investigated, and which possible causes have already been ruled out.

This keeps stakeholders aligned and reduces confusion during an incident.

## 9. Following Up on Postmortem Actions

A postmortem is valuable only when its findings lead to improvements.

Corrective actions should be:

- Clearly documented.
- Assigned to responsible owners.
- Given realistic due dates.
- Tracked until completion.
- Reviewed to confirm that the intended improvement was achieved.

Examples include improving monitoring, updating runbooks, tuning alerts, adding automated checks, reducing deployment risks, and clarifying service ownership.

Without follow-up, postmortems become documentation rather than a mechanism for improving reliability.

## 10. Key Takeaways

- Incident management provides a structured process for detecting, coordinating, responding to, and resolving incidents.
- The priority during an incident is to minimize user impact and restore service.
- Clear ownership helps ensure that every incident has a responsible responder.
- Runbooks provide consistent troubleshooting and recovery guidance.
- On-call schedules and backup responders establish clear incident response coverage.
- Escalation workflows ensure that alerts reach the appropriate responder at the right time.
- Effective communication keeps technical teams and stakeholders aligned.
- Incident readiness requires preparation before incidents happen.
- Sustainable on-call practices protect both service reliability and team well-being.
- Blameless postmortems turn incidents into opportunities for system improvement.
- Corrective actions must be tracked until completion to create lasting reliability improvements.

## 11. Incident Response Principles

| Principle | Purpose |
|---|---|
| Preparation | Establish responsibilities, runbooks, and escalation paths before incidents occur. |
| Detection | Identify reliability problems as early as possible. |
| Ownership | Ensure every incident has a responsible responder. |
| Mitigation | Reduce user impact and restore service quickly. |
| Communication | Keep responders and stakeholders informed. |
| Escalation | Involve the appropriate people when additional support is needed. |
| Recovery | Verify that the service is stable and operating normally. |
| Learning | Understand failures without assigning personal blame. |
| Improvement | Track corrective actions and strengthen system reliability. |