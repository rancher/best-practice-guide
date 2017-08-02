---
title: Kubernetes Setup & Management
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Kubernetes Setup & Management
---

<img src="{{site.baseurl}}/img/bpg/kubernetes.png" width="800" alt="Regional deployment">

For production deployments, it is best practice that each plane runs on dedicated physical or virtual hosts. For development, multi-tenancy may be used to simplify management and reduce costs.

**Data Plane**

Comprised of one or more Etcd nodes which persist state regarding the Compute Plane. Resiliency is achieved by adding 3 hosts to this plane.

**Orchestration Plane**

Comprised of stateless Kubernetes/Rancher components which orchestrate and manage the Compute Plane:
* apiserver
* scheduler
* controller-manager
* kubectld
* rancher-kubernetes-agent
* rancher-ingress-controller) Resiliency is achieved by adding 2 hosts to this plane

**Compute Plane**

Comprised of the real workload (Kubernetes pods), orchestrated and managed by Kubernetes.

