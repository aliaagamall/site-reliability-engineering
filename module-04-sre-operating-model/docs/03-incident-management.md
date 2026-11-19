
# 03 — Incident Management and On-Call

**Area:** 4.3 — Incident Management and On-Call Operations  
**Status:** Design only

## 1. Purpose

This document defines how `shop-api` incidents are detected, handled, and reviewed.

Severity levels are defined in document 02 (SEV1, SEV2, SEV3).

## 2. Incident Lifecycle

| Stage | Action |
|---|---|
| Detect | An alert fires and GoAlert pages the on-call engineer |
| Triage | Acknowledge, open the dashboard, confirm user impact, set severity |
| Escalate | Follow the escalation policy if there is no acknowledgment or help is needed |
| Communicate | Post updates in the incident issue: start, status changes, resolution |
| Mitigate | Restore service first (restart, rollback, or fault removal) using the runbook |
| Resolve | Confirm SLIs recover and the alert clears |
| Follow up | Write a postmortem and track corrective actions |

Mitigation comes before root cause. Investigation continues after service is restored.

Rollback decisions are made by the on-call engineer. Automation and AI suggestions are advisory.

## 3. Response Targets

| Severity | Response target | Postmortem |
|---|---|---|
| SEV1 | Acknowledge within 5 minutes | Required |
| SEV2 | Acknowledge within 15 minutes | Required |
| SEV3 | Triage within the next working day | Optional |

## 4. On-Call with GoAlert

| Item | Design |
|---|---|
| Schedule | Weekly rotation between two engineers |
| Alert routing | Alertmanager sends SEV1 and SEV2 alerts to GoAlert |
| Ownership | The engineer who acknowledges the page owns the incident until resolved or handed off |

### Escalation Policy

| Escalation step | SEV1 | SEV2 |
|---|---|---|
| Step 1 | Notify primary on-call immediately | Notify primary on-call immediately |
| Step 2 | Notify secondary after 5 minutes without acknowledgment | Notify secondary after 10 minutes without acknowledgment |
| Step 3 | Notify SRE lead after 10 minutes without acknowledgment | Notify SRE lead after 20 minutes without acknowledgment |

These escalation intervals are design targets and must be validated during GoAlert configuration and testing.

### Handoff

At the end of a shift, an open incident is handed to the next on-call engineer through a note in the incident issue: current status, actions taken, and next steps. The new owner confirms receipt.

## 5. Incident Records

Each incident is tracked as one GitHub issue using an incident template. The issue records the alert, severity, affected SLO, responder, timeline, recovery action, and whether a rollback was performed.

## 6. Runbooks

Each alert links to a Markdown runbook. A runbook contains: symptoms, checks, recovery steps, and when to escalate.

Runbooks are stored in `runbooks/` and reviewed after each incident.

## 7. Blameless Postmortems

A postmortem is written within 5 working days of a SEV1 or SEV2 incident, using a Markdown template in `postmortems/`.

Template sections: summary, impact, timeline, root cause, what went well, what went wrong, corrective actions.

Postmortems describe system and process failures, not individual mistakes.

### Corrective Actions

Each action becomes a GitHub issue with an owner and a due date, linked from the postmortem. Open actions are reviewed in the SLO review meeting (document 06).

## 8. Incident Scenarios

| Scenario | Trigger | Severity | First response |
|---|---|---|---|
| Increased error rate | Slow-burn alert | SEV2 | Check recent changes, consider rollback |
| High latency | Latency burn-rate alert | SEV2 | Check load and pod resources, restart if needed |
| Service downtime | Service-down alert | SEV1 | Check pods, restart, then roll back if necessary |
| Failed deployment | Error spike after release with user impact | SEV2 | Revert the Git change and allow Argo CD to synchronize the previous desired state |
| Pod crash loop | CrashLoopBackOff for 5 minutes | SEV3 | Check pod events and logs, then follow the runbook |
| Simulated database failure | Error spike during database fault injection | SEV1 | Follow the simulated dependency-failure runbook |
| SLO burn-rate violation | Fast-burn alert | SEV1 | Pause deployments, find the cause, mitigate |

The database failure is simulated through fault injection inside `shop-api`. No real database or external dependency is part of the project.

Each scenario will have a runbook.

## 9. Open Items

- Test GoAlert schedules, escalation, and Alertmanager routing.
- Create the incident issue template and postmortem template.
- Write one runbook per scenario.
- Run one simulated incident and write a real postmortem.
