---
title: Kubernetes Setup & Management - Disaster Recovery
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Disaster Recovery
---

If a majority of hosts running etcd fail, follow these steps:
1. Find an etcd node in Running state (green circle). Click Execute Shell and run command etcdctl cluster-health. If the last output line reads cluster is healthy, then there is no disaster, stop immediately. If the last output line reads cluster is unhealthy, make a note of this etcd. This is your sole survivor, all other containers are dead or replaceable
2. Delete hosts in reconnecting/disconnected state
3. On your sole survivor, click Execute Shell and run command disaster. The container will restart automatically. Etcd will then heal itself and become a single-node cluster. System functionality is restored
4. Add more hosts until you have at least three. Etcd scales back up. In most cases, everything will heal automatically. If new/dead containers are still initializing after three minutes, click Execute Shell and run command delete. Do not, under any circumstance, run the delete command on your sole survivor. System resiliency is restored


