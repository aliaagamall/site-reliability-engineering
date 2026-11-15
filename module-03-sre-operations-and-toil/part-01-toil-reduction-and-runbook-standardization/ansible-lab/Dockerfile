FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANSIBLE_CONFIG=/lab/ansible.cfg

# cron is NOT installed here, so the playbook installs it (shows "changed" on first run)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ansible python3-apt procps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /lab