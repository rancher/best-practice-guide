---
title: Kubernetes Setup & Management - Remote Backups
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Remote Backups
---

After tearing a down a Kubernetes stack, persistent data is left behind. A user may choose to manually delete this data if they wish to repurpose/reuse the hosts.
* A named volume etcd will exist on all hosts which ran etcd at some point. Run docker volume rm etcd on each host to delete it
* Backups are enabled by default and stored to /var/etcd/backups on hosts running etcd. Run ```rm -r /var/etcd/backups/* ``` on one host (if network storage was mounted) or all hosts (if no network storage was mounted) to delete the backups



