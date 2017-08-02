---
title: Kubernetes - Resilient Separated Planes
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Resilient Separated Planes

### Characteristics

* Data Plane resilient to minority of hosts failing 
* Orchestration Plane resilient to all but one host failing 
* Compute Plane resiliency depends on the deployment plan 
* High-performance, production-ready environment 

### Instructions

* Create a Cattle environment 
* Add 3 hosts with 1 CPU, >=1.5GB RAM, >=20GB DISK. Label these hosts etcd=true
 **If you care about backups, [Configuring Remote Backups]({{site.baseurl}}/best-practice/{{page.version}}/{{page.lang}}/kubernetes/management/remote-backups)**


* If you don’t want pods scheduled on these hosts add label nopods=true.
* Add 2 hosts with >=1 CPU and >=2GB RAM. Label these hosts orchestration=true **If you don’t want pods scheduled on these hosts, add label nopods=true**
* Add 1+ hosts without any special labels. Resource requirements vary by workload. 
* Navigate to Catalog > Library. On the Kubernetes catalog item, click View Details. Select your desired version, optionally update configuration options, and click Launch.
 

### Instructions (Rancher v1.1.X and older)

* Create a Cattle environment. 
* Add 3 hosts with 1 CPU, >=1.5GB RAM, >=20GB DISK. Label these hosts etcd=true **If you care about backups, [Configuring Remote Backups]({{site.baseurl}}/best-practice/{{page.version}}/{{page.lang}}/kubernetes/management/remote-backups)**
* If you don’t want pods scheduled on these hosts add label nopods=true.
* Add 2 hosts with >=1 CPU and >=2GB RAM. Label these hosts orchestration=true **If you don’t want pods scheduled on these hosts, add label ```nopods=true```**
* Add 1+ hosts without any special labels. Resource requirements vary by workload. 
* Edit the environment and select Kubernetes 

