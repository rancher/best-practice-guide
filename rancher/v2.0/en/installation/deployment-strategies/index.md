---
title: Rancher Deployment Strategies
layout: bpg-default-v2.0
version: v2.0
lang: en
---

## Hub & Spoke
---
<img src="{{site.baseurl}}/img/bpg/hub-and-spoke.png" width="800" alt="Hub & Spoke deployment">

In this deployment scenario, there is a single Rancher control plane managing compute resources across the globe. The control plane would be run in an HA configuration, and there would be impact due to latencies.

### Pros:

* Environments could have nodes and network connectivity across regions.
* Single control plane interface to view/see all regions and environments.

### Cons:

* Subject to network latencies
* If control plane goes out global provisioning of new services is unavailable until restored.

## Regional
---
<img src="{{site.baseurl}}/img/bpg/regional.png" width="800" alt="Regional deployment">

In the regional deployment model a control plane is deployed in close proximity to the compute nodes.

### Pros:

* Provisioning in regions stay functioning if a control plane in another region go down.

### Cons:

* Overhead of managing multiple Rancher installations.