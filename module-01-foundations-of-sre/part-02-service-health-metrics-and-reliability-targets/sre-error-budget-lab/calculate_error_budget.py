import csv
from datetime import datetime, timezone

SLO = 99.9
MONTH_DAYS = 30
INCIDENT_FILE = "incidents.csv"
REPORT_FILE = "ErrorBudgetSummary.md"

total_minutes = MONTH_DAYS * 24 * 60

error_budget_percentage = 100 - SLO

allowed_downtime = (
    total_minutes * error_budget_percentage / 100
)

incidents = []

with open(INCIDENT_FILE, "r", encoding="utf-8", newline="") as file:
    reader = csv.DictReader(file)

    for row in reader:
        incidents.append({
            "incident_id": row["incident_id"],
            "description": row["description"],
            "downtime": float(row["downtime_minutes"])
        })

consumed_downtime = sum(
    incident["downtime"] for incident in incidents
)

remaining_downtime = allowed_downtime - consumed_downtime

consumed_budget_percentage = (
    consumed_downtime / allowed_downtime * 100
    if allowed_downtime else 0
)

remaining_budget_percentage = (
    max(remaining_downtime, 0) / allowed_downtime * 100
    if allowed_downtime else 0
)

if remaining_downtime <= 0:
    release_decision = "DO NOT RELEASE"
    release_reason = "The error budget has been fully consumed or exceeded."

elif remaining_budget_percentage < 25:
    release_decision = "RELEASE WITH CAUTION"
    release_reason = "Less than 25% of the error budget remains."

else:
    release_decision = "RELEASES CAN CONTINUE"
    release_reason = "Enough error budget remains."

timestamp = datetime.now(timezone.utc).strftime(
    "%Y-%m-%d %H:%M:%S UTC"
)

incident_rows = "\n".join(
    f"| {item['incident_id']} | {item['description']} | "
    f"{item['downtime']:.2f} |"
    for item in incidents
)

report = f"""# Monthly Error Budget Summary

- **Generated at:** {timestamp}
- **Monthly Availability SLO:** {SLO:.1f}%
- **Measurement Window:** {MONTH_DAYS} days

## 1. Initial Error Budget

| Metric | Value |
|---|---:|
| Monthly Availability SLO | {SLO:.1f}% |
| Total Time Window | {MONTH_DAYS} days |
| Total Minutes | {total_minutes:,} |
| Error Budget Percentage | {error_budget_percentage:.2f}% |
| Allowed Downtime | {allowed_downtime:.2f} minutes |

## 2. Incident Details

| Incident ID | Description | Downtime (minutes) |
|---|---|---:|
{incident_rows}

**Total Consumed Downtime:** {consumed_downtime:.2f} minutes

## 3. Error Budget Usage

| Metric | Value |
|---|---:|
| Allowed Downtime | {allowed_downtime:.2f} minutes |
| Consumed Downtime | {consumed_downtime:.2f} minutes |
| Remaining Downtime | {remaining_downtime:.2f} minutes |
| Consumed Error Budget | {consumed_budget_percentage:.2f}% |
| Remaining Error Budget | {remaining_budget_percentage:.2f}% |

## 4. Release Decision

**Decision: {release_decision}**

**Reason:** {release_reason}

## 5. Calculation Notes

- Error Budget = 100% - Availability SLO
- Allowed Downtime = Total Monthly Minutes × Error Budget Percentage
- Consumed Downtime = Sum of all incident downtime values
- Remaining Downtime = Allowed Downtime - Consumed Downtime
- Consumed Budget Percentage = Consumed Downtime / Allowed Downtime × 100
- Remaining Budget Percentage = Remaining Downtime / Allowed Downtime × 100

"""

with open(REPORT_FILE, "w", encoding="utf-8") as file:
    file.write(report)

print(report)
print(f"Report saved to {REPORT_FILE}")
