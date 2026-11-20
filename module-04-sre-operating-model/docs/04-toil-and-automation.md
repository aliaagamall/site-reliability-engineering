# 04 — Toil Reduction and Automation

**Area:** 4.4 — Toil Reduction and SRE Automation  
**Status:** Design only

## 1. Purpose

This document defines how repetitive operational work on `shop-api` is identified and replaced with runbooks and Ansible automation.

## 2. Toil Identification

Toil is manual, repetitive operational work that grows with the service and adds no lasting value.

Potential toil candidates are identified by reviewing incident records, runbook usage, and alert history. These candidates will be validated as operational evidence becomes available.

A task becomes an automation candidate when it is performed repeatedly and follows consistent, well-defined steps.

| Candidate | Source | Automation |
|---|---|---|
| Checking service health | Frequent operational check | Health check playbook |
| Restarting `shop-api` | Repeated incident recovery step | Restart playbook |
| Validating configuration before changes | Repeated manual check | Validation playbook |
| Collecting status during an incident | Repeated first step in runbooks | Health collection playbook |
| Rollback | Recovery after a failed change | Not automated by Ansible; handled through GitOps (document 05) |

## 3. Runbooks

Each runbook in `runbooks/` is a Markdown file with the same sections:

1. Symptoms
2. Checks
3. Recovery steps
4. Automation (playbook to run, if any)
5. Escalation

A runbook first states what to check, then what to run. Automation is a step inside a runbook, not a replacement for it.

## 4. Ansible Playbooks

Playbooks are stored in `ansible/` and run manually by an engineer from their own machine against the local `kind` cluster.

| Playbook | Purpose |
|---|---|
| Health check | Verify that pods are ready and `/health` responds |
| Restart | Restart the `shop-api` deployment and wait until it is ready |
| Configuration validation | Check manifests and configuration before they are applied |
| Health collection | Gather pod status, recent events, and logs into one report |

Health checks, configuration validation, and health collection should be safe to run repeatedly without changing the application state.

The restart playbook is different: it performs a disruptive action and must be explicitly started by an engineer following the relevant runbook. It must not run automatically in response to alerts.

The Ansible modules and approach used to reach the cluster, including how the application health endpoint is accessed, will be decided and verified during implementation.

## 5. When Automation Fails

If a playbook fails or does not restore service:

1. Do not retry in a loop.
2. Save the playbook output in the incident issue.
3. Continue with the manual steps in the runbook.
4. Escalate through GoAlert if service is still degraded (document 03).

## 6. Human Oversight

- Playbooks are started by an engineer, not by alerts.
- The engineer reviews the intended action before running a playbook.
- Playbooks perform only the actions their runbook describes.
- Restart operations require an explicit decision by the engineer.
- A failed playbook is part of the incident record and is reviewed in the postmortem when applicable.

## 7. Measuring Toil Reduction

Toil reduction is reviewed in the SLO review meeting (document 06):

- Number of times each playbook is used.
- Time to recover with and without automation.
- Manual tasks that are still repeated.
- Playbook failures requiring manual intervention.

These measurements will be collected after the playbooks are implemented and used.

## 8. Open Items

- Choose and test how Ansible reaches the `kind` cluster.
- Implement and test the four playbooks, including a failure case.
- Verify that the health check can reach `/health`.
- Write the runbooks and link them to relevant alerts.
