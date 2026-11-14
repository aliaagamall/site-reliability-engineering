# Monthly Error Budget Summary

- **Generated at:** 2026-11-11 20:53:27 UTC
- **Monthly Availability SLO:** 99.9%
- **Measurement Window:** 30 days

## 1. Initial Error Budget

| Metric | Value |
|---|---:|
| Monthly Availability SLO | 99.9% |
| Total Time Window | 30 days |
| Total Minutes | 43,200 |
| Error Budget Percentage | 0.10% |
| Allowed Downtime | 43.20 minutes |

## 2. Incident Details

| Incident ID | Description | Downtime (minutes) |
|---|---|---:|
| INC-001 | Database connection failure | 12.00 |
| INC-002 | API deployment issue | 8.00 |
| INC-003 | Network timeout issue | 5.00 |
| INC-004 | Authentication service failure | 10.00 |

**Total Consumed Downtime:** 35.00 minutes

## 3. Error Budget Usage

| Metric | Value |
|---|---:|
| Allowed Downtime | 43.20 minutes |
| Consumed Downtime | 35.00 minutes |
| Remaining Downtime | 8.20 minutes |
| Consumed Error Budget | 81.02% |
| Remaining Error Budget | 18.98% |

## 4. Release Decision

**Decision: RELEASE WITH CAUTION**

**Reason:** Less than 25% of the error budget remains.

## 5. Calculation Notes

- Error Budget = 100% - Availability SLO
- Allowed Downtime = Total Monthly Minutes × Error Budget Percentage
- Consumed Downtime = Sum of all incident downtime values
- Remaining Downtime = Allowed Downtime - Consumed Downtime
- Consumed Budget Percentage = Consumed Downtime / Allowed Downtime × 100
- Remaining Budget Percentage = Remaining Downtime / Allowed Downtime × 100

