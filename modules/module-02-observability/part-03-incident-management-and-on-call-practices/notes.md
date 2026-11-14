# Part 03: Incident Management and On-Call Practices

## 1. Managing Incidents for Reliable Services

Incident management is the structured process teams follow when a service is disrupted or at risk.

The goal is not only to restore service quickly, but also to reduce user impact and prevent the same problem from happening again.

Effective incident management connects three important principles:

- **Detect Quickly:** Identify problems as early as possible.
- **Respond Clearly:** Coordinate the response with clear ownership and communication.
- **Improve Continuously:** Learn from incidents and reduce the likelihood of recurrence.

### The Incident Management Lifecycle

#### 1. Detection

The first step is identifying that something may be wrong.

Incidents can be detected through:

- Alerts.
- Dashboards.
- Logs.
- Traces.
- User reports.

Examples of possible incident indicators include a spike in errors, slow response times, and failed requests.

#### 2. Triage and Severity Classification

After detection, the team investigates the scope and impact of the issue.

During triage, responders ask:

- Which users are affected?
- Which service or component is involved?
- Is this a small technical issue or a wider business-impacting problem?

The team then assigns a severity level to communicate how urgently the incident needs attention.

A minor internal issue may require normal priority, while a customer-facing outage requires an immediate response.

Clear severity classification helps determine:

- How quickly the team should act.
- Who needs to be involved.
- How frequently updates should be communicated.

#### 3. Escalation, Communication, and Mitigation

After triage, the team moves into active incident response.

**Escalation**

Involve the correct service owner or technical expert as early as possible. Delayed escalation can increase downtime.

**Communication**

Incident updates should include:

- Current incident status.
- User impact.
- Incident owner.
- Expected time for the next update.

**Mitigation**

The immediate priority is to reduce user impact, even if the solution is temporary.

Examples of mitigation actions include:

- Rolling back a deployment.
- Restarting a service.
- Redirecting traffic.
- Disabling a risky feature.

**Key principle:** Restore stability first, then investigate deeper once the service is safe.

#### 4. Resolution and Follow-Up

Incident management does not end when an alert stops firing.

Before declaring an incident resolved, the team should verify that:

- The service is stable.
- Metrics have returned to normal.
- Users are no longer affected.

The team should also document:

- What happened.
- When it happened.
- Which actions were taken.
- What the final resolution was.

Follow-up actions may include fixing bugs, improving monitoring, updating runbooks, changing deployment checks, or strengthening alerting.

---

## 2. Blameless Post-Mortems

A post-mortem turns a resolved incident into an opportunity for shared learning.

The team reviews what happened, why it happened, and what should improve.

The goal is not to blame individuals, but to understand how systems, processes, and decisions contributed to the incident.

### Post-Mortem Process

#### 1. Build an Incident Timeline

Create a clear timeline showing:

- When the issue started.
- When it was detected.
- When the team responded.
- When recovery happened.

#### 2. Identify Contributing Factors

Investigate factors that contributed to the incident, such as:

- Missing alerts.
- Unclear ownership.
- Risky configuration changes.
- Capacity limits.
- Communication gaps.

#### 3. Define Corrective Actions

Capture specific improvements that reduce the chance of recurrence.

A useful post-mortem should be:

- Specific.
- Honest.
- Action-oriented.
- Focused on system and process improvement.

### Expected Post-Mortem Outcomes

A strong blameless post-mortem should produce:

**1. Impact and Root Cause Summary**

Explain what users experienced, which services were affected, and what caused or contributed to the incident.

**2. Assigned Owners and Due Dates**

Every corrective action should have a responsible owner and a realistic deadline.

**3. Review Until Closure**

Track post-mortem actions, verify their completion, and confirm that the improvements are working.

Post-mortem actions should not remain open indefinitely.

---

## 3. On-Call Best Practices

On-call is one of the most critical SRE responsibilities. Poorly managed on-call practices can lead to burnout, slow recovery, and repeated incidents.

Effective on-call work requires clear ownership, appropriate responses, and sustainable team coverage.

### Clear Ownership and Alert Response

When an alert fires, there should be no ambiguity about who is responsible.

On-call engineers should understand when to:

- **Monitor:** Observe the situation to understand its scope and behavior.
- **Acknowledge:** Confirm that the alert has been received and is being handled.
- **Act:** Take the necessary steps when immediate intervention is required.

Not every alert requires the same response. Choosing the appropriate action is essential for effective incident handling.

### Protect Service Reliability During Incidents

The primary responsibility of the on-call engineer is to minimize user impact as quickly as possible.

This may require applying a temporary mitigation while a permanent fix is being prepared.

Decisions and investigation progress should remain visible to the response team.

Engineers should communicate:

- What is currently being investigated.
- Which actions have been attempted.
- What has been ruled out.
- The current incident status.

Silent investigation can create confusion and duplicated work.

### Use Runbooks

Runbooks document operational knowledge and provide instructions for handling known situations.

They may contain:

- Steps to follow.
- Commands to execute.
- Systems to check.
- Troubleshooting guidance.

Using runbooks reduces guesswork under pressure and speeds up incident recovery.

An effective on-call response depends on three things:

1. A clear alert.
2. A named owner.
3. A runbook that guides the response.

---

## 4. Building Sustainable On-Call Coverage

On-call coverage must be structured carefully to remain sustainable over time.

Every on-call setup should define three important roles or responsibilities:

| Role | Responsibility |
|---|---|
| **Primary Responder** | Handles incoming incidents. |
| **Backup Responder** | Supports the primary when they are unavailable, overwhelmed, or need escalation assistance. |
| **Handoff** | Transfers active incident context and responsibilities between outgoing and incoming responders. |

### On-Call Rotation Best Practices

#### 1. Define Primary and Backup Responders

The primary responder handles incoming incidents, while the backup provides an additional layer of support.

Without a backup, incident response depends on a single person.

#### 2. Balance On-Call Shifts

Rotations should be distributed fairly across the team.

Consider:

- Time zones.
- Experience levels.
- Recent incident load.

Repeatedly assigning shifts to the same individuals can lead to burnout.

#### 3. Plan Handoffs

Before a shift ends, the outgoing engineer should brief the incoming engineer.

The handoff should cover:

- Active incidents.
- Actions already investigated.
- Current incident status.
- Issues that still need monitoring.

Poor handoffs can cause incidents to be missed or important context to be lost.

#### 4. Review Rotation Health

After busy periods or intense shifts, evaluate whether the rotation is working effectively.

Consider:

- Are engineers getting enough rest?
- Are incidents clustering around specific shifts?
- Is the backup system actually being used?

---

## 5. Escalation Workflows

Escalation is not a sign of failure. It is an essential part of effective incident response.

The goal is to involve the right people with enough context to resolve the issue efficiently.

An escalation chain moves from the initial responder toward people with increasing capability or authority until the issue is resolved.

### When to Escalate

Escalate when:

- Incident impact is increasing.
- More users or services are affected.
- The problem is beyond the current responder's ability to handle.
- The incident is approaching an SLO breach.

Do not wait until the service becomes completely unavailable.

### Principles of Effective Escalation

#### 1. Escalate at the Right Time

Escalate when the impact, scope, or risk grows beyond what the current responder can manage.

#### 2. Share Complete Context

The receiving responder should not have to start the investigation from zero.

Provide:

- Observed symptoms.
- User and service impact.
- Actions already taken.
- Current incident status.

#### 3. Route to the Right Team

Escalate to the team that has the expertise and access required to resolve the specific issue.

Understanding service ownership helps avoid delays caused by incorrect routing.

#### 4. Keep Communication Clear and Time-Stamped

Use concise, time-stamped updates in a shared communication channel.

This keeps everyone aligned without creating unnecessary noise.

### Three Components of Effective Escalation

1. **Right Trigger:** Escalate when impact, scope, or risk requires additional support.
2. **Continuous Updates:** Share relevant investigation progress and current status.
3. **Drive Toward Resolution:** Involve the right people and keep the response focused on resolving the incident.

---

## 6. Keeping On-Call Manageable

On-call work has a cost in sleep, focus, and trust. Teams should continuously improve their processes to reduce that cost.

### 1. Audit Alert Rules

Regularly review alert rules.

If an alert fires without requiring action, it should not be paging an engineer.

### 2. Improve Runbooks

Repeated incidents should lead to better runbooks.

Update documentation with:

- Better response steps.
- Faster diagnostic checks.
- Clearer troubleshooting guidance.

Runbooks should evolve with operational experience.

### 3. Provide Recovery Time

Engineers who handle intense on-call shifts need adequate recovery time before their next rotation.

Back-to-back intense shifts can negatively affect performance and retention.

### 4. Use Retrospectives

After significant incidents or difficult on-call periods, conduct retrospectives.

The goal is not to assign blame, but to identify:

- What made the experience difficult.
- Which processes caused delays.
- What can be improved for future incidents.

### Desired Outcomes

Effective on-call practices lead to three reinforcing outcomes:

- **Fewer Alerts:** Reduce unnecessary interruptions and burnout.
- **Better Documentation:** Improve runbooks and speed up incident resolution.
- **Healthier Teams:** Help engineers perform effectively under pressure.

---

## 7. Key Takeaways

- Incident management follows a structured process: detection, triage, escalation, communication, mitigation, resolution, and follow-up.
- Severity classification helps determine urgency, ownership, and communication frequency.
- During incidents, reducing user impact is the immediate priority.
- A blameless post-mortem focuses on learning and system improvement rather than individual blame.
- Corrective actions need owners, deadlines, and follow-up until closure.
- Effective on-call requires clear ownership and knowing when to monitor, acknowledge, or act.
- Primary and backup responders provide more reliable incident coverage.
- Fair rotations and planned handoffs help prevent burnout and dropped incidents.
- Escalation should happen at the right time, with sufficient context, and reach the correct team.
- Runbooks, alert reviews, recovery time, and retrospectives make on-call more sustainable.
- Fewer alerts, better documentation, and healthier teams reinforce one another.

## 8. Incident Response Principles

**Detect quickly. Respond clearly. Mitigate user impact. Recover safely. Learn continuously.**

The purpose of incident management and on-call practices is not simply to resolve individual incidents. It is to build stronger, more reliable services while protecting the people responsible for operating them.