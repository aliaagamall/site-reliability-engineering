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
- SLO tracking and burn rate alerts.
- GitOps-based recovery and rollback.
- AI-assisted reliability practices.

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
| 03 | Incident Management and On-Call Practices | Documented  |

### Module 03 — Automation, SLO Tracking, GitOps Recovery, and AI for SRE

Applying automation and reliability engineering practices to reduce operational toil and improve recovery.

| Part | Topic | Status |
|---|---|---|
| 01 | Toil Reduction and SRE Automation | Not Started |
| 02 | SLO Tracking and Reliability Decisions | Not Started |
| 03 | GitOps Recovery and AI-Enhanced SRE | Not Started |

### Module 04 — Course Wrap-Up and Assessment

Consolidating the course concepts through final activities, assessments, and practical application.

## Tools and Technologies

The course explores the following tools and technologies:

- **Operating Systems:** Ubuntu, Linux
- **Containers:** Docker
- **Orchestration:** Kubernetes, kubectl, Helm
- **GitOps:** GitHub, Argo CD
- **Monitoring:** Prometheus, Grafana, PromQL
- **SLO Management:** Pyrra
- **Incident Management:** GoAlert
- **Automation:** Ansible
- **Documentation:** Markdown

Tools are introduced progressively as they become relevant to each topic.

## Repository Structure

```text
site-reliability-engineering/
├── README.md
├── module-01-foundations-of-sre/
│   ├── part-01-introduction-to-sre-and-reliability-thinking/
│   │   └── notes.md
│   └── part-02-service-health-metrics-and-reliability-targets/
│       ├── notes.md
│       ├── sre-error-budget-lab/
│       └── sre-sli-slo-lab/
└── module-02-observability/
    ├── part-01-observability-fundamentals-for-reliable-systems/
    │   ├── notes.md
    │   └── lab-01-sre-environment-setup.md
    ├── part-02-dashboards-and-alerting/
    │   ├── notes.md
    │   ├── kubernetes-monitoring-stack-lab.md
    │   └── lab-slo-dashboard-grafana/
    └── part-03-incident-management-and-on-call-practices/
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

This repository evolves alongside the learning process. New notes, labs, and practical implementations are added as each part of the course is completed.

---

**Focus:** Building reliable, observable, resilient, and maintainable systems through engineering practices.