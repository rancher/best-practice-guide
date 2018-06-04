---
title: Security FAQ's
weight: 2300
draft: true
---

---
This list of questions will continue to be updated

#### Why do I get the following warnings about Rancher containers from Docker Security Benchmark?

**Running as root** Most of our container provide system level functions and as such need root.  Operations include mounting drives, setuping up networking, and binding to ports <1024

**No AppArmorProfile Found** We do not currently set any app armor profile.  Our containers are running as root.  Our containers provide system level functionality so the standard apparmor profile will not apply.

**No SecurityOptions Found** We do not currently set any app armor profile.  Our containers are running as root.  Our containers provide system level functionality so the standard apparmor profile will not apply.

**Container running sshd** These containers do not run sshd.  This is a false positive from the tool.  These containers run with --pid=host and the tool thinks the hosts sshd is owned by these containers, which it is not.

**Container running without memory restrictions** We do not currently set any memory limit on our contianers

**Container running with root FS mounted R/W** We do not run with a r/o root.  All of these container maintain ephemeral state in the container root.

**Privileges not restricted** All of these container provide system level functions that need higher privileges.

**PIDs limit not set** We currently do not set a PID limit, this is from the historical fact that the PID namespace is not available on all platforms we support.  We can look into enabling it for those that do have the PID namespace.

#### How secure is Rancher out of the box?

On first login Rancher requires the setting of a password, in addition to this it uses SSL from the first connection.

#### How does Rancher secure it's communications to the Kubernetes API server?

Rancher secures all communication to Kubernetes with TLS

#### I want to use my own certificates, is that possible?

You can use your own certificates to:

- Terminate ingress connections into the cluster 
- Terminate load balancers that sit in front of the Rancher server
- Bind mount into the Rancher Server container to terminate all traffic to the Rancher server

It is not currently possible to use your own certificates to terminate the Kubernetes API TLS if you provision the Kubernetes cluster via Rancher. If you provision your own Kubernetes cluster you can use what ever you like.

#### Does Rancher do Intrusion Detection?

Rancher does not do intrusion detection, there are several products on the market that specialise in the security of containers. These products can be used in conjunction with Rancher to provide a robust, secure Kubernetes environment.

#### How do I limit communication between containers?

By default all containers within a project can communicate with all others. Rancher uses network policies to limit the communication. A Kubernetes network policy can be supported in our default implementation. More information on network policies can be found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/ "Kubernetes Network Policies")




