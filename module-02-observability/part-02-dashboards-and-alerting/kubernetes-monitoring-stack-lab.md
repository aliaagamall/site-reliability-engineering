# Lab: Kubernetes Monitoring Stack with Prometheus and Grafana

## Objective

Install and configure a complete Kubernetes monitoring stack using Helm, verify that Prometheus collects Kubernetes metrics, and access Grafana dashboards to visualize the monitoring data.

## 1. Lab Environment

The lab uses:

- **Minikube:** Local Kubernetes cluster.
- **Helm:** Kubernetes package manager.
- **Prometheus:** Metrics collection and storage.
- **Grafana:** Metrics visualization and dashboards.
- **Alertmanager:** Alert handling.
- **Node Exporter:** Node-level metrics.
- **Kube State Metrics:** Kubernetes object and resource metrics.

## 2. Verify the Kubernetes Environment

Check the Minikube status:

```bash
minikube status
```

Verify the Kubernetes node:

```bash
kubectl get nodes
```

The Minikube node should appear with a `Ready` status.

Verify Helm installation:

```bash
helm version
```

## 3. Add the Prometheus Community Helm Repository

Add the Helm repository:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update the repository list:

```bash
helm repo update
```

The Prometheus Community repository provides the `kube-prometheus-stack` chart used to install the monitoring components together.

## 4. Create the Monitoring Namespace

Create a dedicated namespace:

```bash
kubectl create namespace monitoring
```

Verify the namespace:

```bash
kubectl get namespaces
```

The `monitoring` namespace keeps monitoring resources separate from application workloads.

## 5. Install the Monitoring Stack

Install the `kube-prometheus-stack` chart:

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring
```

The chart installs an integrated monitoring stack, including:

- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- Kube State Metrics
- Node Exporter
- Kubernetes monitoring rules
- Pre-built Grafana dashboards

Verify the Helm release:

```bash
helm list -n monitoring
```

The release status should be `deployed`.

## 6. Verify Monitoring Pods and Services

Check the monitoring pods:

```bash
kubectl get pods -n monitoring
```

Wait until the monitoring components are running. Some pods may need additional time to start.

Check the services:

```bash
kubectl get services -n monitoring
```

Verify that services for Prometheus, Grafana, and Alertmanager are available.

## 7. Access the Prometheus Dashboard

Start port forwarding to the Prometheus service:

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

Keep the terminal running and open:

`http://localhost:9090`

### Verify Metrics Collection

In the Prometheus query interface, execute:

```promql
up
```

A value of `1` indicates that the monitored target is up and responding to Prometheus scraping.

Multiple targets should appear in the query results.

Stop port forwarding with `Ctrl+C` when finished.

## 8. Retrieve Grafana Admin Credentials

Retrieve the Grafana admin password from the Kubernetes Secret:

```bash
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d
```

The default username is:

```text
admin
```

Keep the retrieved password for the login step.

## 9. Access Grafana

Start port forwarding to Grafana:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Keep the terminal running and open:

`http://localhost:3000`

Log in using:

- **Username:** `admin`
- **Password:** Retrieved from the Kubernetes Secret.

## 10. Verify the Prometheus Data Source

In Grafana:

1. Open **Connections**.
2. Navigate to **Data Sources**.
3. Find the Prometheus data source.
4. Open it and test the connection.

The expected result is a successful connection to the Prometheus API.

The chart normally configures Prometheus as a Grafana data source automatically.

## 11. Explore Kubernetes Dashboards

Open the Grafana dashboard section and search for available Kubernetes dashboards.

Examples include:

- Kubernetes Compute Resources
- Kubernetes Cluster Metrics
- Kubernetes Namespace Metrics
- Node Exporter Metrics

Explore visual metrics such as:

- CPU usage
- Memory usage
- Pod status
- Node metrics
- Namespace-level resource usage

Grafana presents Prometheus metrics through charts and panels, making it easier to understand the health and performance of the Kubernetes environment.

## 12. Final Verification

Run the following commands:

```bash
kubectl get pods -n monitoring
kubectl get services -n monitoring
helm list -n monitoring
```

Confirm that:

- Prometheus, Grafana, Alertmanager, and Exporter pods are running.
- Monitoring services are available.
- The Helm release status is `deployed`.
- Grafana can successfully query Prometheus.
- Kubernetes dashboards display monitoring metrics.

## Expected Outcome

The Kubernetes monitoring stack is successfully installed and operational.

Prometheus collects Kubernetes metrics, while Grafana visualizes them through pre-built dashboards. This provides a foundation for future observability and SRE activities.

## Learning Objectives

- Install Kubernetes monitoring components using Helm.
- Understand the role of the `kube-prometheus-stack` chart.
- Verify Prometheus metrics collection.
- Access Grafana using Kubernetes port forwarding.
- Configure and test the Prometheus data source.
- Explore Kubernetes monitoring dashboards.