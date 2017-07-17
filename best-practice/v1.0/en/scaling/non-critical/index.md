---
title: Setting up non-critical Rancher Environments
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Non-ciritcal Rancher Deployments
---

<img src="{{site.baseurl}}/img/bpg/non-critical.png" width="800" alt="Non-Critical">

In the event the Rancher control plane goes down all running services will not be impacted since the control plane is not part of the services path. During the down time provisioning and service reconciliation become unavailable for the duration of the downtime. If you can tolerate short provisioning down times, you can run Rancher server with the database on a persistent volume (ie. EBS, etc.) or other HA MySQL setup independent of the Rancher server and recover quickly by launching a new Rancher server container pointing at it. 
