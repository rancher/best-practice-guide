---
title: Kubernetes Setup & Management - Configuring Remote Backups
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Configuring Remote Backups
---
With the newest release, full backups of the Data Plane are performed every 15 minutes and deleted after 24 hours, by default. A backup period below 30 seconds is not recommended.

Network storage latency and size should be taken into consideration. 50MB for any single backup is a good estimate for storage requirements. For example, backups created every 15 minutes and retained for 1 day would store a maximum of 96 backups, requiring ~5 GB storage. If there is no intention to ever restore to a previous point in time, fewer historical backups may be retained.

These backups are persisted to a static location /var/etcd/backups on exactly one of the Data Plane hosts. It is imperative that some type of network storage is mounted to this location on all hosts comprising the Data Plane. This must be done before Kubernetes is launched.


