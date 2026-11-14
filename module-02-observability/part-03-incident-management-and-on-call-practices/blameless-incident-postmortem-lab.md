# Lab: Writing a Blameless Incident Postmortem

## Objective

Create a structured incident postmortem for a simulated Backend API incident.

This lab focuses on documenting an incident, understanding its impact, reconstructing the response timeline, identifying contributing factors, and defining corrective actions.

The goal is not simply to record that an incident happened. It is to turn the incident into actionable learning that improves system reliability and incident response.

## 1. Lab Scenario

A Backend API experienced an elevated error rate during a traffic spike.

Some users received intermittent server errors when accessing order-related API endpoints.

The incident lasted approximately 20 minutes. API reliability dropped below the expected SLO.

The investigation identified insufficient database connection pool capacity as the technical cause. During increased traffic, the application could not establish enough database connections, causing some requests to fail.

The response team:

1. Acknowledged the alert.
2. Reviewed API logs and database metrics.
3. Identified the database connection pool limitation.
4. Adjusted the connection pool configuration.
5. Monitored service health after the change.

This is a simulated incident scenario for learning purposes.

## 2. What Is an Incident Postmortem?

An incident postmortem is a structured report created after an incident has been resolved.

It documents:

- What happened.
- When it happened.
- Which users or services were affected.
- How the team detected and responded to it.
- What caused or contributed to the incident.
- What went well and what needs improvement.
- Which actions will reduce the likelihood or impact of similar incidents.

A postmortem should provide a shared understanding of the incident and create a record that the team can use to improve reliability.

### Blameless Postmortem

A blameless postmortem focuses on system behavior, technical conditions, processes, and organizational factors rather than assigning personal blame.

Instead of asking:

"Who made the mistake?"

Ask:

"What conditions allowed this failure to happen, and how can we improve the system?"

This approach encourages people to share accurate information and helps teams identify meaningful improvements.

## 3. Postmortem Sections Explained

The following sections form the structure of the report. Each one answers a different question about the incident.

### 3.1 Incident Title and Date

**Purpose:** Identify the incident clearly and make the report easy to reference.

Include:

- A short, descriptive incident title.
- The date when the incident occurred.
- An incident identifier if the team uses one.

Example:

`Backend API High Error Rate During Traffic Spike`

A clear title helps team members recognize the incident without reading the entire report.

### 3.2 Incident Summary

**Purpose:** Give readers a short overview of what happened.

The summary should explain:

- Which service experienced the issue.
- What behavior was observed.
- How the incident affected normal operation.
- How long the incident lasted, if known.

Example:

The Backend API experienced an elevated error rate during a traffic spike. Some users received intermittent server errors when accessing order-related API endpoints. The incident lasted approximately 20 minutes and caused API reliability to drop below the expected SLO.

The summary should be concise. Detailed technical investigation belongs in later sections.

### 3.3 Impact

**Purpose:** Explain the consequences of the incident from the user and service perspectives.

Consider:

- Which users or requests were affected?
- Which endpoints or features were unavailable or degraded?
- Did the incident affect availability or an SLO?
- How long did the impact last?
- Was data lost or corrupted, if applicable?

Example:

- Some users could not retrieve order information.
- Order-related API requests intermittently returned server errors.
- API reliability dropped below the expected SLO.
- The elevated error rate lasted approximately 20 minutes.

Do not invent exact user counts, request counts, or percentages if they were not measured. Record unknown values as unavailable and identify how they could be measured in the future.

### 3.4 Incident Timeline

**Purpose:** Reconstruct the incident in chronological order, from detection to resolution.

The timeline helps the team understand how the response progressed and where delays occurred.

Record events such as:

1. Monitoring detected the high API error rate.
2. The alert was received.
3. The responder acknowledged the alert.
4. Investigation started.
5. The database connection issue was identified.
6. The configuration was updated.
7. Service health was verified.
8. The incident was resolved.

Use timestamps whenever reliable timestamps are available.

A timeline can help the team evaluate:

- Detection time.
- Acknowledgment time.
- Time to begin investigation.
- Time to mitigate the issue.
- Time to restore normal service.

Do not invent timestamps. Use placeholders until actual incident records or logs are available.

### 3.5 Root Cause and Contributing Factors

**Purpose:** Explain the technical cause of the incident and the conditions that allowed it to occur.

For this scenario, the identified technical cause is insufficient database connection pool capacity during a traffic spike.

The application could not create enough database connections to handle incoming requests, so some API requests failed.

A useful analysis distinguishes between:

- **Root cause:** The technical failure mechanism identified during the investigation.
- **Contributing factors:** Conditions that increased the likelihood, severity, or duration of the incident.

Potential contributing factors to investigate include:

- Connection pool capacity was insufficient for the observed traffic.
- Connection pool utilization was not adequately monitored.
- Load testing may not have covered the traffic level that triggered the failure.

Only record a contributing factor as confirmed when investigation evidence supports it. Otherwise, label it as a hypothesis or follow-up investigation.

### 3.6 Response Actions

**Purpose:** Document what the responders did while handling the incident.

Include the actions in the order they happened.

For this scenario:

1. The alert was acknowledged.
2. API logs were reviewed.
3. Database metrics were inspected.
4. The database connection pool issue was identified.
5. Connection pool settings were adjusted.
6. Service health was monitored after the change.

This section helps future responders understand which actions were taken and how the team restored service.

### 3.7 What Went Well

**Purpose:** Identify response practices that helped the team detect, investigate, or resolve the incident.

Examples to evaluate:

- Monitoring detected the elevated error rate.
- The alert reached a responsible responder.
- API logs and database metrics helped narrow down the issue.
- Service health was checked after the configuration change.

Only include points supported by the incident evidence.

### 3.8 What Could Be Improved

**Purpose:** Identify weaknesses in detection, investigation, communication, or recovery.

Examples to investigate:

- Database connection pool metrics were not sufficiently visible.
- The alert description could provide more diagnostic context.
- A runbook for database connection failures was missing or incomplete.
- Load testing did not cover the traffic conditions that triggered the issue.

This section should describe process and system improvements, not criticize individuals.

### 3.9 Corrective Actions

**Purpose:** Convert lessons from the incident into specific improvement work.

Each action should be clear, actionable, and trackable.

For this scenario:

| Action | Purpose | Owner | Due Date | Status |
|---|---|---|---|---|
| Add database connection pool metrics to Grafana | Improve visibility into connection usage | TBD | TBD | Open |
| Create a database connection failure runbook | Help responders investigate consistently | TBD | TBD | Open |
| Improve the alert description | Provide useful diagnostic context | TBD | TBD | Open |
| Load test the API under higher traffic | Validate connection pool capacity | TBD | TBD | Open |

The owner and due date should be assigned by the team after reviewing the report.

Corrective actions should be reviewed until completion. A report that identifies improvements but never tracks them does not fully achieve its purpose.

### 3.10 Blameless Learning

**Purpose:** Capture the broader lessons from the incident and reinforce a learning-focused response culture.

For this scenario:

The incident exposed a limitation in the application's database connection capacity under increased traffic. The focus should be on improving connection pool configuration, monitoring, load testing, and incident response documentation.

The objective is to understand why the system behaved this way and improve its ability to handle similar conditions in the future.

A blameless approach does not mean avoiding accountability. It means focusing accountability on improving systems, processes, and follow-up actions instead of assigning personal fault.

## 4. Create the Postmortem Document

Create a dedicated working directory:

```bash
mkdir -p ~/sre-postmortem-lab
cd ~/sre-postmortem-lab
```

Create the report:

```bash
touch postmortem.md
```

Open it:

```bash
code postmortem.md
```

Add the following template.

## 5. Postmortem Template

```markdown
# Incident Postmortem: Backend API High Error Rate

## Incident Information

| Field | Value |
|---|---|
| Incident ID | INC-001 |
| Incident Date | [Enter date] |
| Affected Service | Backend API |
| Duration | Approximately 20 minutes |
| Severity | [Assign based on impact] |
| Status | Resolved |

## 1. Incident Summary

The Backend API experienced an elevated error rate during a traffic spike.

Some users received intermittent server errors when accessing order-related API endpoints. The incident lasted approximately 20 minutes and caused API reliability to drop below the expected SLO.

## 2. Impact

- Some users could not retrieve order information.
- Order-related API requests intermittently returned server errors.
- API reliability dropped below the expected SLO.
- The elevated error rate lasted approximately 20 minutes.

## 3. Incident Timeline

| Time | Event |
|---|---|
| [Time] | Monitoring detected the high API error rate. |
| [Time] | The alert was received. |
| [Time] | The responder acknowledged the alert. |
| [Time] | Investigation started. |
| [Time] | The database connection issue was identified. |
| [Time] | Connection pool configuration was updated. |
| [Time] | Service health was verified. |
| [Time] | The incident was resolved. |

## 4. Root Cause and Contributing Factors

### Root Cause

Insufficient database connection pool capacity during a traffic spike prevented the application from establishing enough database connections.

As a result, some API requests failed.

### Contributing Factors

- Database connection pool capacity was insufficient for the observed traffic.
- Connection pool utilization was not adequately monitored.
- Additional load testing may be needed to validate capacity under higher traffic.

## 5. Response Actions

1. The alert was acknowledged.
2. API logs were reviewed.
3. Database metrics were inspected.
4. The database connection pool issue was identified.
5. Connection pool settings were adjusted.
6. Service health was monitored after the change.

## 6. What Went Well

- Monitoring detected the elevated API error rate.
- The alert was acknowledged by a responder.
- API logs and database metrics helped identify the issue.
- Service health was checked after the configuration change.

## 7. What Could Be Improved

- Database connection pool metrics need better visibility.
- A database connection failure runbook should be available.
- Alert descriptions should include more diagnostic context.
- Load testing should cover higher traffic conditions.

## 8. Corrective Actions

| Action | Owner | Due Date | Status |
|---|---|---|---|
| Add database connection pool metrics to Grafana | TBD | TBD | Open |
| Create a database connection failure runbook | TBD | TBD | Open |
| Improve the alert description | TBD | TBD | Open |
| Load test the API under higher traffic | TBD | TBD | Open |

## 9. Blameless Learning

This incident exposed a limitation in the application's database connection capacity under increased traffic.

The focus is on improving connection pool configuration, monitoring, load testing, and incident response documentation.

The incident was a system reliability issue, not an opportunity to assign personal blame.

The goal is to improve the system so that similar traffic conditions are handled more reliably in the future.
```

## 6. Review the Postmortem

Display the complete report:

```bash
cat postmortem.md
```

Display only the incident summary:

```bash
sed -n '/^## 1\. Incident Summary/,/^## 2\. Impact/p' postmortem.md
```

Display the timeline:

```bash
sed -n '/^## 3\. Incident Timeline/,/^## 4\. Root Cause/p' postmortem.md
```

Display corrective actions:

```bash
sed -n '/^## 8\. Corrective Actions/,/^## 9\. Blameless Learning/p' postmortem.md
```

Display the blameless learning section:

```bash
sed -n '/^## 9\. Blameless Learning/,$p' postmortem.md
```

Verify that the file exists:

```bash
ls -l postmortem.md
```

## 7. Validation Checklist

- [ ] The report has a clear incident title and date.
- [ ] The summary explains what happened.
- [ ] The impact section describes user-facing consequences.
- [ ] The timeline follows chronological order.
- [ ] Unknown timestamps are not invented.
- [ ] The root cause explains the technical failure mechanism.
- [ ] Contributing factors are distinguished from confirmed causes.
- [ ] Response actions are documented.
- [ ] Positive response practices are identified.
- [ ] Improvement opportunities are documented.
- [ ] Corrective actions have clear descriptions.
- [ ] Owners and due dates are assigned or explicitly left pending.
- [ ] The report uses blameless language.

## Key Takeaways

- A postmortem records what happened and how the team responded.
- The timeline helps evaluate incident detection and recovery.
- Root cause analysis explains the technical failure mechanism.
- Impact analysis keeps the report focused on users and service reliability.
- Corrective actions turn incident findings into improvement work.
- Blameless learning helps teams improve systems and processes without assigning personal fault.

A postmortem is valuable when its findings lead to measurable improvements in reliability and incident readiness.