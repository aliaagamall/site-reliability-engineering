# Lab 01: SRE Runbook Creation and Standardization

## 1. Objective

Understand how SRE teams create and standardize runbooks to make incident response more consistent, reduce confusion, and improve recovery time.

This lab covers:

- What a runbook is and why SRE teams use it.
- The main sections of a runbook.
- How runbooks support incident investigation and recovery.
- How to create and verify a practical runbook.

## 2. Understanding Runbooks

### What Is a Runbook?

A **runbook** is a documented set of operational instructions that guides engineers through handling a specific operational task, issue, or incident.

It provides clear steps that responders can follow instead of depending entirely on individual experience or trying to figure out what to do during every incident.

Runbooks help teams perform operational tasks in a consistent and organized way.

### Why Are Runbooks Important?

During an incident, responders need to understand the problem, investigate its cause, and take appropriate recovery actions.

Without clear documentation, they may:

- Waste time deciding what to check first.
- Repeat investigation steps.
- Miss important checks.
- Depend on specific individuals who have previous experience.
- Follow inconsistent recovery procedures.

Runbooks address these problems by providing documented response procedures.

### Benefits of Runbooks

- **Consistency:** Different responders can follow the same documented process.
- **Faster Response:** Engineers spend less time figuring out the next steps.
- **Reduced Dependency:** Operational knowledge is not limited to specific individuals.
- **Better Coordination:** Teams know their responsibilities and when to escalate.
- **Improved Reliability:** Documented recovery procedures help teams handle recurring incidents more effectively.

## 3. Anatomy of an SRE Runbook

A good runbook should contain organized sections that guide responders from identifying the issue to confirming recovery.

### 3.1 Issue Description

Explains the operational problem the runbook addresses.

It should clearly identify:

- What is happening?
- Which service or component is affected?
- What is the objective of the response?

### 3.2 Symptoms

Describes how the issue appears from the perspective of users and monitoring systems.

Symptoms may include:

- User complaints.
- Increased error responses.
- Reduced service availability.
- Monitoring alerts.
- Unexpected application behavior.

This section helps responders recognize whether the runbook applies to the current incident.

### 3.3 Initial Checks

Lists the first checks responders should perform to understand the service condition.

These checks may verify:

- Whether the service is reachable.
- Whether the application container is running.
- Whether recent logs contain obvious errors.

The purpose is to quickly confirm the situation before performing deeper investigation.

### 3.4 Investigation Commands

Provides commands and procedures for investigating the issue.

Depending on the environment, these may be used to inspect:

- Application containers.
- Application logs.
- Resource utilization.
- Monitoring metrics.
- Relevant dependencies.

This section gives responders a practical starting point for troubleshooting.

### 3.5 Possible Causes

Lists common explanations that may cause the observed problem.

Examples include:

- Application failures.
- Recent deployments.
- Unavailable databases or dependencies.
- Traffic spikes.
- Configuration problems.

These are possible causes to investigate, not necessarily confirmed root causes.

### 3.6 Recovery Actions

Documents the actions that may help restore normal service operation.

Depending on the incident, recovery actions may include:

- Restarting an application.
- Rechecking service availability.
- Reviewing application logs after recovery.
- Rolling back a problematic deployment.

Recovery actions should be appropriate to the situation and performed with the necessary operational safeguards.

### 3.7 Escalation Steps

Explains when and whom to contact if the incident requires additional support.

A runbook should identify:

- The responsible on-call responder.
- The team to involve when the issue continues.
- When incident leadership should be notified.

Clear escalation guidance prevents delays and helps involve the right people.

### 3.8 Resolution Criteria

Defines how responders can confirm that the incident has been resolved.

For example:

- The service is reachable.
- Error rates have returned to an acceptable level.
- Availability has recovered.
- Application logs no longer show the same recurring errors.
- Monitoring confirms that service health has improved.

The issue should not be considered resolved simply because a recovery command was executed.

## 4. Creating and Maintaining Runbooks

Creating a runbook is not just writing down commands. It requires organizing operational knowledge into a process that another responder can understand and follow.

A practical approach:

1. Identify a recurring operational issue.
2. Describe the problem and its symptoms.
3. Define the initial checks.
4. Document investigation procedures and useful commands.
5. List possible causes.
6. Document recovery actions.
7. Define escalation procedures.
8. Establish clear resolution criteria.
9. Review the runbook after incidents and postmortems.

### Runbook Maintenance

Runbooks should be updated whenever operational experience reveals:

- Missing steps.
- Unclear instructions.
- Outdated commands.
- Better investigation procedures.
- Improved recovery actions.

A runbook is an evolving operational document, not something that should be written once and forgotten.

## 5. Practical Example: High Error Rate on a Backend API

This example demonstrates how the previous concepts can be organized into an actual runbook.

### Scenario

A backend API starts returning a high number of HTTP 500 responses.

Users report failed requests, monitoring detects an increased error rate, and API availability begins to decrease.

The team needs a consistent procedure to investigate and recover the service.

### Example Runbook

#### Issue Description

**Issue:** High Error Rate on Backend API.

The backend API is returning an unusually high number of server-side errors, affecting successful user requests.

**Objective:** Investigate the issue, reduce user impact, and restore normal API operation.

#### Symptoms

- Users report failed API requests.
- Monitoring shows increased HTTP 500 responses.
- Error rate exceeds the defined SLO threshold.
- API availability decreases.

#### Initial Checks

The responder should first verify:

- Is the API reachable?
- Is the application container running?
- Do recent application logs show errors?

#### Investigation Commands

Check API availability:

```bash
curl -i <API_URL>
```

Check running containers:

```bash
docker ps
```

Inspect recent application logs:

```bash
docker logs --tail 100 <CONTAINER_NAME>
```

Check container resource usage:

```bash
docker stats <CONTAINER_NAME>
```

Check the Prometheus metrics endpoint:

```bash
curl -i <PROMETHEUS_URL>/metrics
```

Replace placeholders with the actual environment values.

#### Possible Causes

| Possible Cause | Description |
|---|---|
| Application container stopped | The backend container is no longer running. |
| Recent deployment | A new deployment may have introduced errors. |
| Database or dependency unavailable | The API cannot communicate with a required dependency. |
| Traffic spike | Incoming traffic may have exceeded service capacity. |
| Configuration issue | Incorrect configuration may be causing failures. |

#### Escalation Steps

| Condition | Action |
|---|---|
| Immediately after the alert | Contact the On-Call SRE. |
| Errors continue for 10 minutes | Contact the Backend Team. |
| Customer impact continues for 20 minutes | Contact the Incident Commander. |

These timings are the escalation example used in this lab.

#### Recovery Actions

1. Investigate the application logs and service condition.
2. If restarting is an appropriate recovery action, restart the application container:

```bash
docker restart <CONTAINER_NAME>
```

3. Recheck API availability:

```bash
curl -i <API_URL>
```

4. Review application logs again:

```bash
docker logs --tail 100 <CONTAINER_NAME>
```

5. If the issue started after a deployment, follow the established rollback procedure.

#### Resolution Criteria

The incident is considered resolved when:

- The API is reachable.
- HTTP 500 responses have returned to an acceptable level.
- The error rate is no longer exceeding the defined SLO threshold.
- API availability has recovered.
- Monitoring confirms that service health has improved.

Continue monitoring to make sure the issue does not return.

## 6. Implementing the Lab on Ubuntu

Create a dedicated directory:

```bash
mkdir -p ~/sre-runbook-lab
cd ~/sre-runbook-lab
```

Create the runbook file:

```bash
touch high-error-rate-runbook.md
```

Open the file:

```bash
code high-error-rate-runbook.md
```

Add the practical example from Section 5 and save the file.

### Verify the Runbook

Display the complete file:

```bash
cat high-error-rate-runbook.md
```

Display only the Symptoms section:

```bash
sed -n '/Symptoms/,/Initial Checks/p' high-error-rate-runbook.md
```

Display the Investigation Commands section:

```bash
sed -n '/Investigation Commands/,/Possible Causes/p' high-error-rate-runbook.md
```

Display the Escalation Steps section:

```bash
sed -n '/Escalation Steps/,/Recovery Actions/p' high-error-rate-runbook.md
```

Display the Recovery Actions section:

```bash
sed -n '/Recovery Actions/,/Resolution Criteria/p' high-error-rate-runbook.md
```

Verify that the file exists:

```bash
ls -l high-error-rate-runbook.md
```

## 7. Expected Result

A Markdown runbook that provides a structured response guide for a high error rate incident affecting a backend API.

The runbook should include:

- Issue description.
- Symptoms.
- Initial checks.
- Investigation commands.
- Possible causes.
- Escalation steps.
- Recovery actions.
- Resolution criteria.

The document should be easy to read in the terminal and useful during incident response.

## 8. Key Takeaways

- A runbook is a documented operational procedure for handling a specific task or incident.
- Runbooks reduce confusion and dependency on individual knowledge.
- A good runbook guides responders through identification, investigation, escalation, recovery, and verification.
- Investigation commands provide a consistent starting point for troubleshooting.
- Escalation steps clarify when additional teams or incident leadership should be involved.
- Resolution criteria help confirm that service health has actually recovered.
- Runbooks should be reviewed and updated after incidents and postmortems.

**Main Principle:** A good SRE runbook turns operational knowledge into a repeatable process that helps teams respond faster and more consistently.