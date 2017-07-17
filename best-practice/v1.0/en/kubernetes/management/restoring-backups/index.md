---
title: Kubernetes Setup & Management - Restoring Backups
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Restoring Backups
---
Backup restoration will only work for Resilient Separated-Planes deployments. If all hosts running etcd fail, follow these steps:
1. Change your environment type to ```Cattle```. This will tear down the Kubernetes system stack. Pods (the Compute plane) will remain intact and available

2. Delete reconnecting/disconnected hosts and add new hosts if you need them
3. Ensure at least one host is labelled ```etcd=true```
4. For each ```etcd=true``` host, mount the network storage containing backups, then run these commands:<br>
```#configure this to point to the desired backup in /var/etcd/backups```<br>
```target=2016-08-26T16:36:46Z_etcd_1```<br>
```don’t touch anything below this line```<br>
```docker volume rm etcd docker volume create --name etcd docker run -d -v etcd:/data --name etcd-restore busybox docker cp /var/etcd/backups/$target etcd-restore:/data/data.current docker rm etcd-restore```
<br>**Note - you must be logged in as a user with read access to the remote backups. Otherwise, the docker cp command will silently fail**
5. Change your environment type back to Kubernetes. The system stack will launch and your pods will be reconciled. Your backup may reflect a different deployment topology than what currently exists; pods may be deleted/recreated


