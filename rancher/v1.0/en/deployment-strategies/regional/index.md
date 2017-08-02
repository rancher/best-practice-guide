---
title: Rancher Deployment Strategies
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Regional
---
<img src="{{site.baseurl}}/img/bpg/regional.png" width="800" alt="Regional deployment">

In the regional deployment model a control plane is deployed in close proximity to the compute nodes.

### Pros:

* Provisioning in regions stay functioning if a control plane in another region go down.

### Cons:

* Overhead of managing multiple Rancher installations.