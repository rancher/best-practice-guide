---
layout: single
author_profile: true
title: Kubernetes Setup & Management - Failure Recovery
layout: bpg-default-v1.0
version: v1.0
lang: en
---

## Failure Recovery
---

If a host enters reconnecting/disconnected state,attempt to re-run the agent registration command. Wait 3 minutes. If the host hasn’t re-entered active state
1. Add a new host with similar resources and host labels 
2. Delete the old host from the environment. 
Containers will be scheduled to the new host and eventually become healthy.


