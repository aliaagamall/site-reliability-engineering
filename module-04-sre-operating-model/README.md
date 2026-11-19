# Module 04 — SRE Operating Model for CloudNova Systems

**Building a measurable, observable, and resilient operating model for cloud-native services.**

CloudNova Systems is a fictional cloud-native company operating customer-facing services on Kubernetes. As its services grow, maintaining reliability requires more than keeping workloads running. The organization needs a structured approach to defining reliability targets, detecting service degradation, responding to incidents, reducing operational toil, and recovering safely from failures.

This project designs and gradually implements a practical Site Reliability Engineering (SRE) operating model to address these challenges.

The model brings together six essential SRE capabilities:

- **Reliability Measurement:** Define Service Level Indicators (SLIs), Service Level Objectives (SLOs), and error budgets to measure reliability and guide operational decisions.
- **Observability:** Collect and analyze metrics, visualize service health, and detect reliability risks through dashboards and actionable alerts.
- **Incident Management:** Establish incident response workflows, on-call responsibilities, escalation procedures, runbooks, and blameless postmortems.
- **Toil Reduction:** Automate repetitive operational tasks through health checks, recovery procedures, and configuration validation.
- **GitOps Recovery and AI:** Use Git as the source of truth for infrastructure and application configuration, support controlled recovery, and explore AI-assisted anomaly detection and incident analysis.
- **Governance and Continuous Improvement:** Maintain version-controlled operational practices, traceable changes, documented decisions, and evidence-based reliability reviews.

The project follows a design-first approach, then moves into a hands-on implementation using a local Kubernetes environment. Each capability is documented, implemented where applicable, and validated through practical scenarios.

**The objective is to demonstrate how SRE principles can turn reliability from an informal operational responsibility into a measurable, repeatable, and continuously improving engineering practice.**

This is a standalone project with its own application, configurations, documentation, and evidence. It does not depend on or reuse implementations from earlier repository modules.

## Project Approach

The project is built design-first:

1. Define the scope, architecture, and SRE strategy.
2. Prepare the report and presentation structure.
3. Implement each component step by step on a local `kind` cluster.
4. Record evidence (screenshots, command output) for everything that is implemented.

## Status Legend

Every capability in this project is labeled honestly:

| Label | Meaning |
|---|---|
| **Implemented** | Built and verified in the local environment, with evidence |
| **Configured** | Configuration exists but has not been fully tested |
| **Design only** | Documented as a workflow or proposal, not built |
| **Planned** | Not started yet |

## Requirement Areas

| Area | Topic | Status |
|---|---|---|
| 4.1 | Reliability measurement and SLO strategy | Planned |
| 4.2 | Observability, dashboards, and alerting | Planned |
| 4.3 | Incident management and on-call operations | Planned |
| 4.4 | Toil reduction and SRE automation | Planned |
| 4.5 | GitOps recovery and AI-enhanced SRE | Planned |
| 4.6 | Governance, traceability, and operational quality | Planned |

## Planned Structure

This structure will evolve as the project develops. Folders are created only when they have content.

```text
module-04-sre-operating-model/
├── README.md
├── docs/          # design documents, report, slides, diagrams, evidence
├── app/           # shop-api and load generator
├── cluster/       # kind configuration and scripts
├── k8s/           # Kubernetes manifests
├── monitoring/    # Prometheus, Grafana, Pyrra, alert rules
├── oncall/        # GoAlert setup
├── runbooks/      # Markdown runbooks
├── postmortems/   # postmortem template and reports
├── ansible/       # automation playbooks
├── gitops/        # Argo CD applications and deployable manifests
└── ai/            # anomaly detection and incident summaries
```

## Environment

- Local Kubernetes using `kind`
- No cloud resources required