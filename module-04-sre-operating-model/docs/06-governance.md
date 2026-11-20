# 06 — Governance, Traceability, and Operational Quality

**Area:** 4.6 — Governance, Traceability, and Operational Quality  
**Status:** Design only

## 1. Purpose

This document defines how reliability decisions and operational changes are recorded, reviewed, and traced.

## 2. Configuration and Operational Records in Git

Project configuration, automation, and operational documentation are version-controlled in Git.

| Item | Location | Format |
|---|---|---|
| SLO definitions | `monitoring/` | YAML |
| Alert rules | `monitoring/` | YAML |
| Grafana dashboards | `monitoring/` | JSON |
| Kubernetes manifests managed by Argo CD | `gitops/` | YAML |
| Runbooks | `runbooks/` | Markdown |
| Postmortems and template | `postmortems/` | Markdown |
| Ansible playbooks | `ansible/` | YAML |
| Statistical detector | `ai/` | Python |

Operational data such as metrics, alert history, and Argo CD sync history remains in the tools that collect or manage it.

Git history records changes to version-controlled files, including what changed, who changed it, and when.

## 3. Change Review

Changes are proposed through pull requests and checked against a template.

GitHub-specific files live in the repository root `.github/`:

| File | Purpose |
|---|---|
| Pull request template | Checklist: what changed, which SLO or service is affected, how it was tested, rollback plan |
| CODEOWNERS | Assigns required reviewers to SLO, alert, and automation changes |
| Incident issue template | Records an incident (document 03) |
| Corrective action issue template | Tracks postmortem actions (document 03) |

Changes to SLOs, alert rules, and automation require review by someone other than the author.

CODEOWNERS identifies the reviewers responsible for specific files. Branch protection or repository rules must be configured to enforce required approvals and prevent unauthorized direct changes to `main`.

For this project, direct commits to `main` are used during the build, and the pull request process is demonstrated with at least one change.

## 4. Reviews

| Review | When | Purpose |
|---|---|---|
| SLO review | Every 4 weeks | Check SLO attainment and Error Budget, review targets, open corrective actions, playbook usage, and toil |
| Post-incident review | After each SEV1 or SEV2 | Complete the postmortem and corrective actions |
| Release checkpoint | Before each release | Check the Error Budget status against the release policy (document 01) |

Review outcomes are recorded in a short Markdown note in the repository.

## 5. Deployment and Rollback History

- Deployment changes are recorded as Git commits in `gitops/`.
- Argo CD maintains the sync history for the application.
- A rollback is a revert commit linked from the incident issue (document 05).

## 6. Automation Change Tracking

Playbook and script changes follow the same pull request process.

Each playbook run during an incident is recorded in the incident issue with its output (document 04).

## 7. Incident Traceability

Each incident issue links the records needed to answer the key questions.

| Question | Where the answer is recorded |
|---|---|
| Which SLO was affected? | Incident issue, SLO field |
| Which alert fired? | Incident issue, alert name and link |
| Which service was impacted? | Incident issue, service field |
| Who responded? | Incident issue, responder, and GoAlert history |
| What recovery action was taken? | Incident issue timeline |
| Was a rollback performed? | Incident issue, with a link to the revert commit |
| What corrective actions were created? | Postmortem, linked to action issues |
| What happened to the Error Budget? | Incident issue, with Pyrra values or snapshots from before and after the incident, when available |

Error Budget changes are evaluated using the SLO measurement window. An incident does not automatically consume Error Budget; only requests that violate the defined SLI contribute to the budget.

## 8. Open Items

- Create the `.github/` templates and CODEOWNERS.
- Configure repository rules or branch protection to enforce required reviews.
- Demonstrate one change through a pull request.
- Create the SLO review note template.
- Define how Pyrra values are captured and linked to incident records.
- Link one simulated incident across the issue, alert, revert commit, and postmortem.
