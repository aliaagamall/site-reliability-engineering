# Site Reliability Engineering

**A structured learning journey into Site Reliability Engineering principles and practices.**

This repository documents my learning journey in Site Reliability Engineering (SRE), combining technical notes, practical exercises, hands-on labs, and implementation examples.

The goal is to develop a deeper understanding of how reliable systems are designed, monitored, operated, and continuously improved.

## Learning Objectives

Throughout this repository, I explore:

- Site Reliability Engineering principles and reliability thinking.
- SRE and DevOps alignment.
- Reliability, availability, and resilience.
- Service Level Indicators (SLIs) and Service Level Objectives (SLOs).
- Error budgets and reliability policies.
- Monitoring, observability, and alerting.
- Incident management and on-call operations.
- Automation, toil reduction, and runbooks.
- Reliability reviews and release decisions.
- Production readiness and operational risk management.
- GitOps-based deployments and recovery.
- AI-assisted anomaly detection and incident analysis.

## Course Roadmap

### Module 01 — Foundations of Site Reliability Engineering

Understanding SRE principles, reliability goals, and the relationship between software engineering and operations.

| Part | Topic | Status |
|---|---|---|
| 01 | Introduction to SRE and Reliability Thinking | Documented |
| 02 | Service Health Metrics and Reliability Targets | Documented |

### Module 02 — Observability

Exploring observability fundamentals, monitoring dashboards, alerting strategies, and incident response workflows.

| Part | Topic | Status |
|---|---|---|
| 01 | Observability Fundamentals for Reliable Systems | Documented |
| 02 | Dashboards, Alerts, and SLO Monitoring | Documented |
| 03 | Incident Management and On-Call Practices | Documented |

### Module 03 — SRE Operations, Reliability Decisions, and Intelligent Automation

Applying operational engineering practices to reduce toil, make evidence-based reliability decisions, improve deployment safety, and strengthen recovery using GitOps and AI-assisted approaches.

| Part | Topic | Status |
|---|---|---|
| 01 | Toil Reduction and Runbook Standardization | Documented |
| 02 | Reliability Reviews and Release Decisions | Documented |
| 03 | GitOps and AI for Site Reliability Engineering | Documented |

### Module 04 — SRE Operating Model

A standalone capstone project that designs and gradually implements an SRE operating model for a fictional Kubernetes-based company. It follows a design-first approach and is implemented step by step on a local `kind` cluster.

| Project | Description | Status |
|---|---|---|
| [SRE Operating Model for CloudNova Systems](module-04-sre-operating-model/README.md) | SLOs, observability, incident management, automation, GitOps recovery, AI-assisted SRE, and governance | In progress (design phase) |

## Tools and Technologies

The course explores the following tools and technologies:

- **Operating Systems:** Ubuntu, Linux
- **Containers:** Docker
- **Orchestration:** Kubernetes, kubectl, Helm
- **GitOps:** GitHub, Argo CD, Flux
- **Monitoring:** Prometheus, Grafana, PromQL
- **SLO Management:** Pyrra
- **Incident Management:** GoAlert
- **Automation:** Ansible
- **AI and Anomaly Detection:** Prophet, Isolation Forest, LangChain, LLMs
- **Documentation:** Markdown

Tools are introduced progressively as they become relevant to each topic.

## Repository Structure

```text
site-reliability-engineering/
├── README.md
│
├── module-01-foundations-of-sre/
│   ├── part-01-introduction-to-sre-and-reliability-thinking/
│   │   └── notes.md
│   │
│   └── part-02-service-health-metrics-and-reliability-targets/
│       ├── notes.md
│       ├── sre-error-budget-lab/
│       └── sre-sli-slo-lab/
│
├── module-02-observability/
│   ├── part-01-observability-fundamentals-for-reliable-systems/
│   │   ├── notes.md
│   │   └── lab-01-sre-environment-setup.md
│   │
│   ├── part-02-dashboards-and-alerting/
│   │   ├── notes.md
│   │   ├── kubernetes-monitoring-stack-lab.md
│   │   └── lab-slo-dashboard-grafana/
│   │
│   └── part-03-incident-management-and-on-call-practices/
│       ├── notes.md
│       ├── goalert-on-call-escalation-lab.md
│       └── blameless-incident-postmortem-lab.md
│
└── module-03-sre-operations-and-toil/
    ├── part-01-toil-reduction-and-runbook-standardization/
    │   ├── notes.md
    │   └── runbook-creation-and-standardization.md
    │
    ├── part-02-reliability-reviews-and-release-decisions/
    │   └── notes.md
    │
    └── part-03-gitops-and-ai-for-site-reliability-engineering/
        └── notes.md
```

Each module is organized into individual parts. Each part contains the documentation and practical work relevant to its topics.

Depending on the lesson, a part may include:

- `notes.md` — Technical explanations, concepts, and key takeaways.
- Lab directories — Hands-on exercises, application code, and configuration files.
- Lab documentation — Setup instructions, implementation steps, and validation results.
- Supporting assets — Screenshots, dashboards, and other practical evidence.

Not every part requires a practical lab.

## Learning Approach

Each topic is documented using a consistent approach:

1. Understand the underlying concepts and principles.
2. Document technical explanations and important details.
3. Explore relevant tools and commands.
4. Perform practical exercises when applicable.
5. Record implementation steps, validation, and results.
6. Review and consolidate key takeaways.

## Progress

Modules 01, 02, and 03 have been documented, covering SRE foundations, observability, incident management, operational practices, reliability decisions, GitOps, and AI-assisted SRE.

Module 04, a standalone SRE operating model project, is in progress and currently in its design phase.

The repository will continue to evolve through the remaining course activities, assessments, and practical implementations.

---

**Focus:** Building reliable, observable, resilient, and maintainable systems through engineering practices.