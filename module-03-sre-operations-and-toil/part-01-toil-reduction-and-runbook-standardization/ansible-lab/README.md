# Ansible SRE Lab
Hands-on lab for automating routine SRE tasks with Ansible. A playbook runs health checks, restarts a service, and writes a health report. Ansible runs locally inside an Ubuntu container, so no remote hosts or SSH setup are needed.

Part of: `module-03-sre-operations-and-toil / part-01-toil-reduction-and-runbook-standardization`

## Objectives

- Run Ansible in a disposable Docker container
- Define a local inventory and test it with the `ping` module
- Automate checks: uptime, root disk usage, memory usage
- Ensure a service is installed, check its status, and restart it
- Generate a health report file
- Prove repeatability (idempotency) by re-running the playbook

## Structure

```
ansible-lab/
├── Dockerfile                    # Ubuntu 24.04 + Ansible (cron intentionally not installed)
├── docker-compose.yml            # Long-running lab container, lab dir mounted at /lab
├── ansible.cfg                   # Inventory path, disable host key checking
├── inventory.ini                 # Single target: local connection
├── .gitignore
└── playbooks/
    └── sre-health-check.yml      # Checks + cron restart + report
```

## Prerequisites

| Tool | Check |
|---|---|
| Docker Engine / Desktop | `docker --version` |
| Docker Compose v2 | `docker compose version` |

## Quick start

```bash
cd module-03-sre-operations-and-toil/part-01-toil-reduction-and-runbook-standardization/ansible-lab

docker compose build
docker compose up -d
docker compose exec ansible ansible local -m ping
docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml
docker compose exec ansible cat /tmp/sre_health_report.txt
```

## Lab steps

| # | Step | Command |
|---|---|---|
| 1 | Build and start the container | `docker compose build && docker compose up -d` |
| 2 | Verify Ansible | `docker compose exec ansible ansible --version` |
| 3 | Inspect inventory | `docker compose exec ansible ansible-inventory --list` |
| 4 | Test connection | `docker compose exec ansible ansible local -m ping` |
| 5 | Syntax check | `docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml --syntax-check` |
| 6 | Dry run | `docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml --check` |
| 7 | Run playbook | `docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml` |
| 8 | View report | `docker compose exec ansible cat /tmp/sre_health_report.txt` |
| 9 | Verify cron | `docker compose exec ansible service cron status` |
| 10 | Re-run playbook | `docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml` |

Step 6 (`--check`) may report errors on tasks that depend on earlier changes, for example the cron status check before cron is installed. This is expected in check mode. Use step 7 for the real run.

## Playbook tasks

| Task | Module | Purpose |
|---|---|---|
| Check system uptime | `command` | Detect recent restarts |
| Check root disk usage | `command` | Catch full-disk risk |
| Check memory usage | `command` | Detect memory pressure |
| Ensure cron is installed | `apt` | Idempotent install |
| Check cron status | `command` | Capture state before the action |
| Restart cron | `service` | Sample recovery action |
| Create health report | `copy` | Save results to `/tmp/sre_health_report.txt` |

## Expected results

| Run | cron install | cron restart | Report |
|---|---|---|---|
| 1st | `changed` | `changed` | created |
| 2nd | `ok` | `changed` | `changed` (new timestamp) |

- Play recap should end with `failed=0`.
- First run: report shows `cron is not running` under "Cron status before restart".
- Second run: report shows `cron is running`.
- The restart always reports `changed`, because restart is not idempotent by nature.
- The install task turning from `changed` to `ok` is the idempotency proof.

## Design notes

- `ansible_connection=local`: tasks run inside the container, no SSH.
- `use: service` on the restart task: the container has no systemd, so Ansible uses the SysV init script.
- The container runs as root, so `become` is not required.
- `cron` is left out of the image so the first run shows a real install.
- The lab directory is bind-mounted at `/lab`, so edits on the host apply immediately without a rebuild.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `service cron status` fails right after `up` | cron is not installed yet. Run the playbook first. |
| `Failed to find required executable` for apt | Image built without `python3-apt`. Run `docker compose build --no-cache`. |
| `Could not resolve host` during apt | Container has no network. Check Docker DNS/proxy settings. |
| Playbook edits not picked up | Confirm the volume mount: `docker compose exec ansible ls /lab/playbooks` |
| Warning about world-writable config dir | Mounted dir permissions are too open. Run `chmod o-w .` on the host, or set `ANSIBLE_CONFIG` explicitly (already done in the Dockerfile). |

## Useful extras

```bash
# Verbose output
docker compose exec ansible ansible-playbook playbooks/sre-health-check.yml -v

# Ad-hoc command through Ansible
docker compose exec ansible ansible local -m command -a "df -h /"

# Interactive shell inside the lab container
docker compose exec ansible bash
```

## Cleanup

```bash
docker compose down              # stop and remove container (report in /tmp is deleted)
docker compose down --rmi local  # also remove the built image
```

## Extension ideas

- Add a second container as a remote target and switch the inventory to SSH
- Add a `handlers:` section so the restart only triggers when something changed
- Add a threshold check that fails the play when disk usage exceeds 80%
- Fetch the report back to the host with the `fetch` module
- Turn the checks into a role under `roles/sre_health/`