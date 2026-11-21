# shop-api Docker Test Results

- **Date (UTC):** 2026-11-21 13:26:40
- **Docker:** Docker version 29.1.2, build 890dcca
- **Image:** `shop-api:1.0.0` (188MB)
- **Container exit code after crash:** 3
- **Command:** `app/docker-test.sh`
- **Result:** 9 of 9 checks passed

## Checks

| Check | Expected | Actual | Result |
|---|---|---|---|
| Image builds | yes | yes | PASS |
| Container starts and /health responds | yes | yes | PASS |
| POST /checkout returns 200 | 200 | 200 | PASS |
| GET /metrics returns 200 | 200 | 200 | PASS |
| GET /admin/faults returns 200 when ADMIN_ENABLED=true | 200 | 200 | PASS |
| Container runs as non-root user | 10001 | 10001 | PASS |
| POST /admin/crash returns 202 | 202 | 202 | PASS |
| Container stops after the crash request | yes | yes | PASS |
| Container exits with a non-zero exit code | yes | yes | PASS |

The crash test stops the container. This is a process crash, not a Kubernetes
CrashLoopBackOff, which is tested later in the cluster.
