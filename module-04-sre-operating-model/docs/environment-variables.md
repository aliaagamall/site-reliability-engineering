# Environment Variables

Every environment variable used by the project is listed here. A new variable is added to this file in the same commit that introduces it.

## Rules

1. **Non-secret values** are documented here and set in code, scripts, or manifests.
2. **Secrets are never committed.** They live in a git-ignored `.env` file or are generated at install time, and reach the cluster as Kubernetes Secrets created by a script.
3. A secret gets a placeholder entry in `.env.example` and a row in the Secrets table below.
4. Kubernetes Secrets are only base64-encoded, not encrypted. Lab values only; never reuse real credentials.

## Application

| Variable | Used by | Value | Secret | Purpose |
|---|---|---|---|---|
| `ADMIN_ENABLED` | `app/app.py` | `false` in `Dockerfile`, `true` in `k8s/10-deployment.yaml` | No | Enables the `/admin/*` testing endpoints. Lab only; they have no authentication |
| `PYTHONUNBUFFERED` | `app/Dockerfile` | `1` | No | Sends logs to the container output immediately |
| `PYTHONDONTWRITEBYTECODE` | `app/Dockerfile` | `1` | No | Avoids writing `.pyc` files in the image |

## Test Script Options

Optional overrides for the scripts in `tests/`. The defaults work for the standard setup.

| Variable | Used by | Default | Secret | Purpose |
|---|---|---|---|---|
| `PORT` | `smoke-test.sh`, `docker-test.sh`, `loadgen-test.sh` | `8080` | No | Local port for the app under test |
| `PORT_NOADMIN` | `smoke-test.sh` | `8081` | No | Port for the instance started without admin endpoints |
| `PORT_DOWN` | `loadgen-test.sh` | `8099` | No | Port with nothing listening, for the unreachable-app test |
| `LOCAL_PORT` | `k8s-test.sh` | `18080` | No | Local port for `kubectl port-forward` |
| `REPORT` | every script in `tests/` | `docs/evidence/<test-name>.md` | No | Output path of the Markdown report |

## Secrets

None yet. Expected as the project grows:

| Secret | Needed in |
|---|---|
| Grafana admin password | Monitoring setup |
| GoAlert database password and admin credentials | On-call setup |
| Alertmanager to GoAlert integration key | Alert routing |

No GitHub token is needed because Argo CD reads a public repository.

## Shell Helper

The commands in this project's documentation use `$M` as a shortcut for the module folder. It is defined in `env.sh`, which is not a secret:

```bash
source module-04-sre-operating-model/env.sh
```

| Variable | Defined in | Value | Secret | Purpose |
|---|---|---|---|---|
| `M` | `env.sh` | `module-04-sre-operating-model` | No | Shortcut for the module path in terminal commands. The scripts do not depend on it |

The scripts always use the explicit `kind-cloudnova-sre` kubectl context, so no `KUBECONFIG` or context variable is needed.
