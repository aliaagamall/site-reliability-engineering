# 05 — GitOps Recovery and AI-Enhanced SRE

**Area:** 4.5 — GitOps Recovery and AI-Enhanced SRE  
**Status:** Design only

## 1. Purpose

This document defines how `shop-api` is deployed and recovered through GitHub and Argo CD, and how statistical analysis supports incident detection and response.

## 2. GitOps Design

| Item | Design |
|---|---|
| Source of truth | Kubernetes manifests in the `k8s/` folder of the GitHub repository |
| Argo CD Application definition | YAML configuration stored in the `argocd/` folder |
| Argo CD Application | One application defined in `argocd/` that watches `k8s/` and deploys to the `shop` namespace |
| Repository access | Public repository for this project. A private repository with a read-only token is also supported by Argo CD but is not implemented |
| Sync | Automatic sync from Git |
| Drift handling | Self-heal is disabled so drift stays visible as `OutOfSync` and an engineer decides what to do |

Sync and drift settings are design choices and must be verified during implementation.

## 3. Drift Detection

Argo CD compares the live cluster with the Kubernetes manifests in `k8s/`. If they differ, for example after a manual `kubectl` change, the application shows as `OutOfSync`.

The engineer then chooses:

- Sync to restore the Git state.
- Commit the change to Git if it was intentional.

## 4. Rollback Workflow

Rollback is performed through a Git revert, not a manual cluster change.

1. Identify the faulty commit using the deployment history in Git.
2. Revert the commit in Git.
3. Argo CD detects the new commit and syncs the previous stable manifests.
4. Verify recovery: the application is `Synced` and `Healthy`, pods are ready, and the SLIs and alerts recover.
5. Record the rollback in the incident issue, linking the revert commit.

The on-call engineer decides when to roll back. Nothing is rolled back automatically.

Traceability: Git history shows what changed, who changed it, and when. The revert commit and incident issue link the failure to the recovery.

## 5. Scenarios Requiring Rollback

| Issue | Typical signal | GitOps action |
|---|---|---|
| Faulty application version | Error spike after release | Revert the release commit |
| Broken Kubernetes manifest | Argo CD shows sync error or degraded resource | Revert the manifest change |
| Incorrect container image tag | Pods stuck in `ImagePullBackOff` | Revert to the previous image tag |
| Failed deployment sync | Application stays `OutOfSync` or `Degraded` | Revert the faulty change and sync again |
| Application crash loop | `CrashLoopBackOff` alert after a change | Revert the change that caused it |
| Service availability issue | Fast-burn or service-down alert after a change | Revert the latest relevant change |

The demonstration will use a deliberately faulty image tag. The faulty version itself is decided during implementation.

## 6. Statistical Reliability Assistance

The reliability analysis component is a small Python script using statistical methods and fixed rules, not a trained machine learning model. It reads metrics from Prometheus and produces findings and recommendations for an engineer.

| Capability | Design |
|---|---|
| Anomaly detection | Compare request rate, error rate, and p95 latency with a recent baseline. Flag values when their Z-score is above 3 or below -3 for several consecutive checks |
| Alert grouping | Group related anomalies and alerts within the same time window into one incident candidate for engineer review |
| Incident summary | Generate a draft containing the alert, affected SLO, anomalous metrics, and recent Git changes |
| Suggested remediation | Use a fixed mapping from alert type to the matching runbook and recovery step |
| Error budget projection | Estimate when the Error Budget may be exhausted if the current burn rate continues |

### Detection Rules and Limitations

- Positive Z-scores above 3 indicate unusually high values.
- Negative Z-scores below -3 indicate unusually low values.
- Request rate anomalies must be interpreted in context. A traffic decrease does not automatically indicate an application failure.
- Anomaly findings are investigation signals, not confirmed incidents.
- If the baseline standard deviation is zero or too close to zero, the detector must handle the case safely and avoid division by zero.
- The baseline requires enough representative observations of normal traffic.
- Z-score detection may produce false positives when traffic has seasonal or changing patterns. These limitations are accepted for this project.

## 7. Data Sources

| Input | Source |
|---|---|
| Request rate, error rate, and latency | Prometheus metrics |
| Affected SLO | Prometheus and Pyrra SLO data |
| Recent changes | Git commit history |
| Runbook recommendations | Fixed alert-to-runbook mapping |

The script will use Git history to identify recent changes. Linking a specific commit to an incident remains a review task for the engineer.

## 8. Human Oversight

- The Python script only reads data and writes text. It does not restart, roll back, or change anything.
- Summaries and remediation suggestions are drafts marked as statistically generated.
- The on-call engineer reviews the findings before using them and makes every recovery decision.
- Anomaly findings do not automatically create confirmed incidents.
- If the output is wrong or missing, the engineer follows the runbook as usual.

## 9. Open Items

- Store the Argo CD Application definition in `argocd/`, point it to `k8s/`, and verify sync and drift behavior.
- Choose how the faulty version is produced.
- Test a rollback through Git revert and verify recovery.
- Implement the statistical detector and test it with controlled traffic.
- Define the baseline window and consecutive-check requirements.
- Test zero-variance handling and review false positives.
- Verify access to Prometheus, Pyrra, and Git history.