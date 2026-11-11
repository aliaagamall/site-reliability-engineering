# SLI & SLO Measurement Lab

A hands-on lab for building a sample Flask application, generating HTTP traffic, and measuring service reliability using Service Level Indicators (SLIs).

## Overview

The application provides two endpoints:

- `/` – Application health check.
- `/orders` – Simulated orders API with randomized response latency and an 8% failure probability.

The lab generates 50 HTTP requests and records their status codes and response times.

## SLIs

The following indicators are calculated:

- **Availability:** Percentage of successful requests.
- **Error Rate:** Percentage of failed requests.
- **Latency:** Percentage of requests completed within 500 ms.

## Technologies

- Python
- Flask
- Ubuntu
- curl

## Project Files

| File                   | Description                                    |
| ---------------------- | ---------------------------------------------- |
| `app.py`               | Sample Flask application                       |
| `generate_traffic.py`  | Generates 50 HTTP requests and records results |
| `calculate_sli.py`     | Calculates the SLIs                            |
| `TrafficResultsLog.md` | Request results and response times             |
| `SLI-Report.md`        | Final SLI measurement report                   |

## Run the Lab

```bash
# Activate the virtual environment
source venv/bin/activate

# Start the application
python app.py
```

Open another terminal:

```bash
cd sre-sli-slo-lab
source venv/bin/activate

# Generate traffic
python generate_traffic.py

# Calculate SLIs
python calculate_sli.py
```

## Expected Results

The lab produces:

- Total and successful request counts.
- Failed request count.
- Availability percentage.
- Error rate percentage.
- Percentage of requests completed within 500 ms.

Results vary between runs because latency and failures are randomized.

## Learning Objectives

- Understand practical SLI measurement.
- Measure application availability and latency.
- Observe HTTP failures.
- Connect application behavior with reliability metrics.
