# Module 04 — SRE Operating Model for CloudNova Systems

**A practical SRE operating model built around a single application on Kubernetes.**

CloudNova Systems is a fictional company that needs a structured approach to application reliability.

This project develops and implements an SRE operating model around one Python HTTP application, `shop-api`, running on a local Kubernetes `kind` cluster.

The application exposes a checkout operation and supports controlled failure scenarios. This makes it possible to practice reliability measurement, monitoring, incident response, automation, and recovery without real customer traffic or cloud infrastructure.

## SRE Capabilities

The project covers six areas:

- **Reliability Measurement:** Define SLIs, SLOs, Error Budgets, and release policies.
- **Observability:** Collect metrics, build Grafana dashboards, and configure actionable alerts.
- **Incident Management:** Define incident response, on-call escalation, runbooks, and postmortems.
- **Toil Reduction:** Automate operational checks and recovery tasks using Ansible.
- **GitOps Recovery and AI:** Manage application configuration through GitOps, test rollback procedures, and build a lightweight anomaly detector.
- **Governance and Continuous Improvement:** Track changes, document decisions, and review reliability practices.

## Project Approach

The project follows a design-first approach:

1. Define the scope and architecture.
2. Document the SRE capabilities and operational workflows.
3. Implement the application and supporting tools.
4. Test reliability and recovery scenarios.
5. Capture evidence and update the project report.

## Status Legend

| Status | Meaning |
|---|---|
| **Implemented** | Built and verified with evidence |
| **Configured** | Configuration exists but has not been fully tested |
| **Design only** | Documented but not implemented |
| **Planned** | Not started yet |

## Requirement Areas

| Area | Topic | Status |
|---|---|---|
| 4.1 | Reliability Measurement and SLOs | Design only |
| 4.2 | Observability, Dashboards, and Alerting | Design only |
| 4.3 | Incident Management and On-call | Planned |
| 4.4 | Toil Reduction | Planned |
| 4.5 | GitOps Recovery and AI | Planned |
| 4.6 | Governance and Continuous Improvement | Planned |

## Project Structure

Folders will be created as their implementation begins.

```text
module-04-sre-operating-model/
├── README.md
├── docs/          # Design documents, report, presentation, and evidence
├── app/           # shop-api and load generator
├── cluster/       # kind configuration and scripts
├── k8s/           # Kubernetes manifests
├── monitoring/    # Prometheus, Grafana, Pyrra, and alert rules
├── oncall/        # GoAlert configuration
├── runbooks/      # Operational procedures
├── postmortems/   # Postmortem template and reports
├── ansible/       # Operational automation
├── gitops/        # Argo CD configuration
└── ai/            # Anomaly detection and incident summaries
```

## Environment

- Python application: `shop-api`
- Local Kubernetes: `kind`
- Monitoring: Prometheus and Grafana
- SLO tracking: Pyrra
- Alerting: Alertmanager and GoAlert
- GitOps: GitHub and Argo CD
- Automation: Ansible
- No cloud resources required
