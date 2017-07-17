---
title: Scaling Rancher
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Scaling Rancher
---

Depending on your use case you should select one of the options below. Things to keep in mind though, is that Rancher servers need to have fast access to the MySQL database.

Servers should not access databases outside of a region or metro area. The first bottleneck a user would hit coming from a POC/Hello World environment is likely to be database.

Rancher server processes perform better with lots of Ram. By default, without changing the settings, Rancher will allocate a max heap of (~½) the hosts ram.  Outside of POC testing Rancher server should be run on a host of its own.
Rancher scales better using multiple environments vs. single large environments. When planning out your usage, Rancher environment level should be a top level consideration.
