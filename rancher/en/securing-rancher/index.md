---
title: Securing Rancher
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Securing Rancher
---

#### Least Privilege Network Access
Restricting network access to only required ports/protocols is a good practice for reducing security risk. Rancher only requires a few types of network access:

- Rancher Node to Server: `443/tcp`(ssl) or `8080/tcp`. This is a web socket connection so applying firewalls/IDS that try to inspect HTTP traffic may cause issues.
- Rancher Node to Node: `500/udp` & `4500/udp`. This is to support `ipsec` connectivity between Rancher
nodes. **Note**: If you are using `vxlan` the port requirements will be different.

Using cloud providers like AWS, you can restrict traffic between hosts using security groups to only the above hosts.

#### Reduce Operating System Packages
For the operating system on your Rancher nodes you will likely need far less packages than you would for a traditional workload. This is because the docker images for your containers will contain all the libraries and packages needed to run those workloads. Removing unnecessary packages reduces the chances of having an un-patched exploit ([CVE](https://nvd.nist.gov/)), and further reduces the burden on your IT team to quickly deploy a patch when it is discovered. To make this easier, consider an already minimalist operating system such as [CoreOS](https://coreos.com/os/docs/latest), [Atomic](https://www.projectatomic.io/), or [RancherOS](http://rancher.com/rancher-os/).

#### Clean Room Production Environment
Containers offer powerful tooling to enable fully immutable infrastructure. This allows you to make changes by deploying new infrastructure, rather than trying to mutate it in place. Additionally this enables you to operate with minimal or no humans in the production environment. By disabling shell/ssh access to your Rancher nodes, you make it a lot harder for an attacker to gain access and compromise the system. And since your engineers can deploy easily from Rancher with confidence about the outcome, they don't need to logon to production to validate their changes, or make last minute config fixes because its so difficult to do a deploy. Adding diagnostic tools and data capture tools for debugging can help eliminate the other common needs for interactive logon. If users can run a tool that captures memory dumps or state of a running process unattended, they won't miss having interactive access to get their work done.

#### Docker Image Trust
Docker images contain one of broadest attack surfaces as these contain a variety of binaries that are usually somewhat opaque to the end user. Only use Docker images from known sources. Official repos from the Docker Store give some level of confidence, but even then CVEs can slip into images unbeknownst to the image author.  You can use an image scanning tool like [Anchore](anchore.io) (open source) for better insight into known CVEs in a given image, even restricting your build process to only allow images with a certain threshold of CVE.

#### Web Application firewalls
These technologies seek to understand traffic at the application level to prevent requests that appear malicious. Some users have reported good success with tools like https://github.com/SpiderLabs/ModSecurity-nginx, however they do require careful configuration which is beyond the scope of this document. WAF is valuable tool for the Rancher UI/API interface however, especially if you expose this endpoint to a large/unsecured group of users.
