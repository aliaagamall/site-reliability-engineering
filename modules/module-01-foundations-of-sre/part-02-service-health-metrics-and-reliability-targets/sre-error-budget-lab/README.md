# Error Budget Calculation Lab

A hands-on Python lab for calculating a monthly error budget from an availability SLO, tracking incident-related downtime, and making release decisions.

## Overview

This lab uses a **99.9% monthly availability SLO** over a 30-day measurement window.

It calculates the allowed downtime, measures consumed budget using simulated incidents, and determines whether releases can continue.

## Scenario

The lab includes four simulated incidents:

| Incident                       |       Downtime |
| ------------------------------ | -------------: |
| Database connection failure    |     12 minutes |
| API deployment issue           |      8 minutes |
| Network timeout issue          |      5 minutes |
| Authentication service failure |     10 minutes |
| **Total**                      | **35 minutes** |

## Technologies

- Python
- Ubuntu
- CSV
- Markdown

## Project Files

| File                        | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `calculate_error_budget.py` | Calculates error budget usage and release decisions |
| `incidents.csv`             | Stores incident details and downtime                |
| `ErrorBudgetSummary.md`     | Final error budget report                           |

## Run the Lab

```bash
# Navigate to the project directory
cd sre-error-budget-lab

# Run the calculator
python3 calculate_error_budget.py
```

## Expected Results

| Metric                 | Expected Value |
| ---------------------- | -------------: |
| Availability SLO       |          99.9% |
| Error Budget           |          0.10% |
| Allowed Downtime       |  43.20 minutes |
| Consumed Downtime      |     35 minutes |
| Consumed Error Budget  |         81.02% |
| Remaining Downtime     |   8.20 minutes |
| Remaining Error Budget |         18.98% |

## Release Decision

**RELEASE WITH CAUTION**

Less than 25% of the error budget remains, so risky releases should be avoided.

## Learning Objectives

- Understand the relationship between SLOs and error budgets.
- Calculate allowed monthly downtime.
- Track downtime caused by incidents.
- Measure consumed and remaining error budgets.
- Use error budget status to guide release decisions.
