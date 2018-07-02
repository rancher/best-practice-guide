---
title: Ingress
weight: 2300
draft: true
version: v2.0
lang: en
---

---

### Introduction

The standard scenario to provide access to services running at k8s cluster is throught ingress controller.

<img src="../img/service-SSL_ingress.jpg" width="800" alt="Ingress">

TLS certificates if configured and virtual servers are managed by nginx ingress controller.

To maintain and operate this configuration, tls certs and FQDN's for every service, needs to be configured at ingress controller. External dns's entries for every FQDN should point to k8s nodes running ingress controller.

### TLS

If you want to secure the access to the service, you need to generate a TLS cert/key for every service `hello-world.mycompany.io` or generate a wildcard for a domain `*.mycompany.io`. It will generate a secret in the configured namespace, with tls cert/key data, that could be used by ingress to secure service. 
  
```
$ kubectl -n default get secret
NAME                  TYPE                                  DATA      AGE
default-token-6sb6b   kubernetes.io/service-account-token   3         3d
mycompany-io          kubernetes.io/tls                     2         1h
```

Once you add tls cert/key to ingress, forward to https is mandatory unless you add annotation to  `nginx.ingress.kubernetes.io/ssl-redirect: "false"` 

Note: TLS cert/key should be generated to match FQDN with tls CN (Common Name) or SAN (Subject Alternative Name). If not, ingress nginx will fail to configure tls, showing  this error `ssl certificate default/test does not contain a Common Name or Subject Alternative Name for host hello-world.mycompany.io. Reason: x509: certificate is valid for *.otherdomain.io, not hello-world.mycompany.io`

### Deploying

Let's see an example with a `hello-world` example.

A user wants to deploy and expose a `hello-world` service in rancher, with service fqdn `hello-world.mycompany.io`

#### Requirements
  - Rancher system with a deployed or imported k8s cluster.
  - DNS entry for service fqdn `hello-world.mycompany.io`, pointing to k8s cluster nodes running ingress.
  - TLS certificate for `hello-world.mycompany.io` or wildcard for `*.mycompany.io`.

#### Deploy service from UI

  - At rancher ui, go to `Workload` page on your rancher project, and click on `Deploy` button. Scale 2 and using port mapping 80 as "cluster IP". 

  <img src="../img/create_workload.png" width="800" alt="Create workload">

  <img src="../img/generated_workload.png" width="800" alt="Generated workload">

  - Rancher will generate service automatically, due to port mapping was configured. If you don't configure port mapping, ingress rule will generate service in the form `INGRESS_*` 

  <img src="../img/generated_service.png" width="800" alt="Generated service">

  - If you want to secure the access to the service, generate a TLS cert/key for `hello-world.mycompany.io` or wildcard for `*.mycompany.io`. It will generate a secret in the configured namespace, with tls cert and key, that would be used by ingress to secure service.
  
  ```
  $ kubectl -n default get secret
  NAME                  TYPE                                  DATA      AGE
  default-token-6sb6b   kubernetes.io/service-account-token   3         3d
  mycompany-io          kubernetes.io/tls                     2         1h
  ```

  At rancher ui, go to `Resources` -> `Certificates` and click the button `Add certificate`. 

  TLS key should be in pkcs#1 pem format, be sure that header and footer are `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`. If you find headers like `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`, or `-----BEGIN ENCRYPTED PRIVATE KEY-----` and `-----END ENCRYPTED PRIVATE KEY-----`, key is in pkcs#8 format and needs to be converted to pkcs#1. `openssl rsa -in <PKCS8_KEY> -out <PKCS1_KEY>`

  <img src="../img/create_certificate.png" width="800" alt="Create certificate">

  - Create ingress rule pointing to `hello-world` service and setting `hello-world.mycompany.io` requested host.

  <img src="../img/create_ingress.png" width="800" alt="Create ingress">

  Configure certificate

  <img src="../img/ingress_certificate.png" width="800" alt="Ingress certificate">

  <img src="../img/generated_ingress.png" width="800" alt="Generated ingress">

  - Once ingress is deployed, at workload view you should see new service entrypoint. Clicking on it, service site will be opened at `http://hello-world.mycompany.io` or `https://hello-world.mycompany.io` depending if you use tls or not.

  <img src="../img/entrypoint_workload.png" width="800" alt="Entrypoint for workload">

  Check that `hello-world.mycompany.io` dns entry, points to your k8s cluster nodes ip's running ingress. 

#### Importing yaml manifest

  - If you want to secure the access to the service, generate a TLS cert/key for `hello-world.mycompany.io` or wildcard for `*.mycompany.io`. It will generate a secret in the configured namespace, with tls cert and key, that would be used by ingress to secure service.
  
  ```
  $ kubectl -n default get secret
  NAME                  TYPE                                  DATA      AGE
  default-token-6sb6b   kubernetes.io/service-account-token   3         3d
  mycompany-io          kubernetes.io/tls                     2         1h
  ```

  To create certficate, you could do it from ui (see previous section) or from manifest like that. 

  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: mycompany-io
    namespace: default
  type: Opaque
  data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhakNDQWxJQ0NRQ3BXKzJCUkhYR1F6QU5CZ2txaGtpRzl3MEJBUXNGQURDQmdERUxNQWtHQTFVRUJoTUMKUlZNeEVqQVFCZ05WQkFnVENVTmhkR0ZzYjI1cFlURVNNQkFHQTFVRUJ4TUpRbUZ5WTJWc2IyNWhNUkF3RGdZRApWUVFLRXdkeVlYZHRhVzVrTVI4d0hRWUpLb1pJaHZjTkFRa0JGaEJ5WVhWc1FISmhkMjFwYm1RdWJtVjBNUll3CkZBWURWUVFERkEwcUxuSmhkMjFwYm1RdWJtVjBNQjRYRFRFNE1EY3dNakE0TXpBek9Gb1hEVEU1TVRFeE5EQTQKTXpBek9Gb3diVEVMTUFrR0ExVUVCaE1DVlZNeEN6QUpCZ05WQkFnVEFrTkJNUkl3RUFZRFZRUUhFd2xEZFhCbApjblJwYm04eEZUQVRCZ05WQkFvVERGSmhibU5vWlhJZ2JHRmljekVOTUFzR0ExVUVDeE1FVkdWemRERVhNQlVHCkExVUVBeFFPS2k1dGVXTnZiWEJoYm5rdWFXOHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUsKQW9JQkFRRFkzOHhaTXUvbFBjbDNwMEZ1MWNhaHVFZjRUKzJZZ2gwclN4azVNaXZEbDhCOTNlQzRRSmEwT2ZwOQoyVUhVQWJNNWU0dE9iSmtjSHl4VjU3QnNOOHFzVHY0VDVJTzBZZFBUU1BHMGZRWmVJc2pMRVVlRkNuam5aS0hUClZ3VjNLM3dndWVLdVBtK25TZUxKSmhQSkdNaytVak5vL3VKa2c3YmpReGJTVzdVSEM5UGRMUTRad1lERmIwbzIKWXBEajVvYTd6NEMya0k5STNGVDVQT1Vka2s1UXhKV2NGWG82Ujd6SVFrSTRFWHpDWVB4QWRiakQ1OUhWUDZDQQpwaStUaVllSjZHK0lheWZnYVcyU05mdnl1NmhBUGsyMGl1NjRpNnQ4MUtQai8yS2pFTWlTaXBleHdseWQvU1NiCmcySWE3dVFLU0ptUy9oUFR4clVYSzUwNXo3VjdBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDM3oKeGdlb05LaStzOHBSeFY4U0t1T0hNZzhsa3UwV1lSRjRabFdvYi9Nb2ZGeHI0bmk1UmNTNFdKOEVCV0g3K0ZwQgpmNWk2bU0zZm9JZjdRb1lKN0d1RUJ4Z01rOW5NMDBkVDNGOVI4MjZ6d2xlYU41VDRPRWJxZkhPRXR1UWdUMzdECkFydnpDRnMxcXgxbmd5ejBlYU1yajFzQmdhZCtPQWNKc3NMN1lGQUZnbkZIbThNaG13bGVlZEdMeCtBazRSMm4Kd2RMQTI0QW1YLzZ4aHBwbVdnQ0E3MzJHdUVleXNKbnpSa0tMY3NtRWorSjdDcHdUU1ZyaEZScU05aGxnbGlBWQo3NG12OW1KUTFkZTFMakphREp4YVNvYlJVUlAxSEg4N01GWC9sYlNaZGxyNmNFOEJ0TEZwaC9kSnNwQ0VYVXdiCjNIQ1ZDVllTVXhlcjVwSTZzUFU9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBMk4vTVdUTHY1VDNKZDZkQmJ0WEdvYmhIK0UvdG1JSWRLMHNaT1RJcnc1ZkFmZDNnCnVFQ1d0RG42ZmRsQjFBR3pPWHVMVG15WkhCOHNWZWV3YkRmS3JFNytFK1NEdEdIVDAwanh0SDBHWGlMSXl4RkgKaFFwNDUyU2gwMWNGZHl0OElMbmlyajV2cDBuaXlTWVR5UmpKUGxJemFQN2laSU8yNDBNVzBsdTFCd3ZUM1MwTwpHY0dBeFc5S05tS1E0K2FHdTgrQXRwQ1BTTnhVK1R6bEhaSk9VTVNWbkJWNk9rZTh5RUpDT0JGOHdtRDhRSFc0CncrZlIxVCtnZ0tZdms0bUhpZWh2aUdzbjRHbHRralg3OHJ1b1FENU50SXJ1dUl1cmZOU2o0Lzlpb3hESWtvcVgKc2NKY25mMGttNE5pR3U3a0NraVprdjRUMDhhMUZ5dWRPYysxZXdJREFRQUJBb0lCQVFDakU2WVZiTGYzS1A3VgplbTg1YUlaMEZKNEptaENQSFVmUnhpYXhXNGlOQ3c4emxpUGthS3pwMks4Qzh0c05FRG8wZnpIQlJ1ZmF2WllaCkFwOG13TTBseEVCSnRRdFVHRHV3SkttYmptZTdZV3liUmVNQnAxNUNvT2tPZ2VFYU94aWJneXR3Mm9JYXlQUS8KVE9LVDFJOSt6VkRiSXM0Wnh2RSs4ck8yZWo4bGk5eThOZk5BVjhUOWdTZTBLKzBSVUkrQUoxQ3J4KzNudFRHdgpTbExpTFBjTVZ5NkhmanJkUzFtK2swQ2xMSXowWkZObVBLVHRaN3NvY1N1S2p3bGdTSDhncEMyb29wZUkwYW5LCjlMSjlaa0ZTTGJ2cThrZFZRNWZncmpNcWlUWlJRSlJhY1Z3Y2szUDZSUnE1ME5hbXFEQVY0RXIvSDhyWi9EMU8KK0dlNzFUZ0JBb0dCQVBNTFJHODhxRTFhRlBWUVd5aUllK1BMeG9HWC94OVJRVmZOVENzZzgyTFZNZmRRd1FhYgpvS20zV1BUMTQzOWVQNytFenowdUN0NDBON3pMa0ZYUEtuRFc3MldjSjdGa3NzdHFMSnRzbVIvL2dzbEFpVi9SCnVrcjRoaGN0U1hmTzJmKzFBa2lDc0VRT3lqWHgwYzNEcXpTVWNvOVRzSWl4L0JKSDlGRVFHeENUQW9HQkFPUnYKWnJZdjAxcmZXaU5xbE4yN2d4R1AvKzY2c3pjelJHcGRLcENIbDg2WHdqQVdrVWZzYXZIRWl1S1RaaisycUlMVQpLMmxwNlYvdDd0bkJhakdnQ2lWeVNtdEU4cXdlRTNZZk8remx3Y3AwQlVDQVpsMzlYbkR6cHVJSGhOKzRWWUk5CjZ4bnFxdkhyL2tzWUxkWTJzRWk4NWlrQTZNRUdLTytORzhCQlU2QjVBb0dCQUo3ek5uMTljU0N0a2xsaGhVeTcKL2pKYnVlWlZicytmaDVtUnRZZmJVL0hHTnBobFl1Z2NiZld3NkdmRVRGV25ZUSt6SHdvSEM2cUpBZzdpSHZKUAp1NVR5ckx5S1pOYzZZVWh4bHR6TEtGWHArRElBbUJkbmhXdTBuNVdXMDU2Y1ZLeE1TRUw5M2FPVS9LQk5GNFozCnVvZDNzbmlVSmpjd0dBZ29zTnMzS2t3ckFvR0JBSnpXYjZxK2cxcHM1ekpSeHd2RjVtTjBmcitscDg1S2dMcVcKWk5iK2daZnlVZjA2UVYwa1VQalZmSlc3cGdRd29OblNXa3Z4ejYxeGF3Qk83MTVMQnl4V29BbXVPUDg3VnhsTwpzSkloM1QvbkVJUU1wRHY3N1krWGVnak9LTWlCZ3hQODl5SEFJTVlneFdOQm9wYmt6WHZqVmhMbzhPVTJHWHovCllRSksxK1BoQW9HQVkvYUtJYU9TY2xaN2J6ZjhVNWFTbFdtMzg2MlRxZGRRUCtGdDNnUXVjSmZzM1orTnlXbzcKZW9oU2E2UXl3U3p5LzJzV0VhVUxzR1BvcnkvdGRYOEhnM1ZyUndwdXNyK3JxeURvNDBRYzN0aEVPd2FsL21FWgpKVkc5R3E1dWFhK2FwbGpIa2U1NkRZaHdISk1relNIakVGMDlKeFZvYWU4V2hqVk43UTNBYjdJPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
  ```

  - Service manifest, including deployment, service and ingress with optional tls.

  ```
  # Optional secret for TLS certs
  apiVersion: v1
  kind: Secret
  metadata:
    name: mycompany-io
    namespace: default
  type: secret
  data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhakNDQWxJQ0NRQ3BXKzJCUkhYR1F6QU5CZ2txaGtpRzl3MEJBUXNGQURDQmdERUxNQWtHQTFVRUJoTUMKUlZNeEVqQVFCZ05WQkFnVENVTmhkR0ZzYjI1cFlURVNNQkFHQTFVRUJ4TUpRbUZ5WTJWc2IyNWhNUkF3RGdZRApWUVFLRXdkeVlYZHRhVzVrTVI4d0hRWUpLb1pJaHZjTkFRa0JGaEJ5WVhWc1FISmhkMjFwYm1RdWJtVjBNUll3CkZBWURWUVFERkEwcUxuSmhkMjFwYm1RdWJtVjBNQjRYRFRFNE1EY3dNakE0TXpBek9Gb1hEVEU1TVRFeE5EQTQKTXpBek9Gb3diVEVMTUFrR0ExVUVCaE1DVlZNeEN6QUpCZ05WQkFnVEFrTkJNUkl3RUFZRFZRUUhFd2xEZFhCbApjblJwYm04eEZUQVRCZ05WQkFvVERGSmhibU5vWlhJZ2JHRmljekVOTUFzR0ExVUVDeE1FVkdWemRERVhNQlVHCkExVUVBeFFPS2k1dGVXTnZiWEJoYm5rdWFXOHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUsKQW9JQkFRRFkzOHhaTXUvbFBjbDNwMEZ1MWNhaHVFZjRUKzJZZ2gwclN4azVNaXZEbDhCOTNlQzRRSmEwT2ZwOQoyVUhVQWJNNWU0dE9iSmtjSHl4VjU3QnNOOHFzVHY0VDVJTzBZZFBUU1BHMGZRWmVJc2pMRVVlRkNuam5aS0hUClZ3VjNLM3dndWVLdVBtK25TZUxKSmhQSkdNaytVak5vL3VKa2c3YmpReGJTVzdVSEM5UGRMUTRad1lERmIwbzIKWXBEajVvYTd6NEMya0k5STNGVDVQT1Vka2s1UXhKV2NGWG82Ujd6SVFrSTRFWHpDWVB4QWRiakQ1OUhWUDZDQQpwaStUaVllSjZHK0lheWZnYVcyU05mdnl1NmhBUGsyMGl1NjRpNnQ4MUtQai8yS2pFTWlTaXBleHdseWQvU1NiCmcySWE3dVFLU0ptUy9oUFR4clVYSzUwNXo3VjdBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDM3oKeGdlb05LaStzOHBSeFY4U0t1T0hNZzhsa3UwV1lSRjRabFdvYi9Nb2ZGeHI0bmk1UmNTNFdKOEVCV0g3K0ZwQgpmNWk2bU0zZm9JZjdRb1lKN0d1RUJ4Z01rOW5NMDBkVDNGOVI4MjZ6d2xlYU41VDRPRWJxZkhPRXR1UWdUMzdECkFydnpDRnMxcXgxbmd5ejBlYU1yajFzQmdhZCtPQWNKc3NMN1lGQUZnbkZIbThNaG13bGVlZEdMeCtBazRSMm4Kd2RMQTI0QW1YLzZ4aHBwbVdnQ0E3MzJHdUVleXNKbnpSa0tMY3NtRWorSjdDcHdUU1ZyaEZScU05aGxnbGlBWQo3NG12OW1KUTFkZTFMakphREp4YVNvYlJVUlAxSEg4N01GWC9sYlNaZGxyNmNFOEJ0TEZwaC9kSnNwQ0VYVXdiCjNIQ1ZDVllTVXhlcjVwSTZzUFU9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBMk4vTVdUTHY1VDNKZDZkQmJ0WEdvYmhIK0UvdG1JSWRLMHNaT1RJcnc1ZkFmZDNnCnVFQ1d0RG42ZmRsQjFBR3pPWHVMVG15WkhCOHNWZWV3YkRmS3JFNytFK1NEdEdIVDAwanh0SDBHWGlMSXl4RkgKaFFwNDUyU2gwMWNGZHl0OElMbmlyajV2cDBuaXlTWVR5UmpKUGxJemFQN2laSU8yNDBNVzBsdTFCd3ZUM1MwTwpHY0dBeFc5S05tS1E0K2FHdTgrQXRwQ1BTTnhVK1R6bEhaSk9VTVNWbkJWNk9rZTh5RUpDT0JGOHdtRDhRSFc0CncrZlIxVCtnZ0tZdms0bUhpZWh2aUdzbjRHbHRralg3OHJ1b1FENU50SXJ1dUl1cmZOU2o0Lzlpb3hESWtvcVgKc2NKY25mMGttNE5pR3U3a0NraVprdjRUMDhhMUZ5dWRPYysxZXdJREFRQUJBb0lCQVFDakU2WVZiTGYzS1A3VgplbTg1YUlaMEZKNEptaENQSFVmUnhpYXhXNGlOQ3c4emxpUGthS3pwMks4Qzh0c05FRG8wZnpIQlJ1ZmF2WllaCkFwOG13TTBseEVCSnRRdFVHRHV3SkttYmptZTdZV3liUmVNQnAxNUNvT2tPZ2VFYU94aWJneXR3Mm9JYXlQUS8KVE9LVDFJOSt6VkRiSXM0Wnh2RSs4ck8yZWo4bGk5eThOZk5BVjhUOWdTZTBLKzBSVUkrQUoxQ3J4KzNudFRHdgpTbExpTFBjTVZ5NkhmanJkUzFtK2swQ2xMSXowWkZObVBLVHRaN3NvY1N1S2p3bGdTSDhncEMyb29wZUkwYW5LCjlMSjlaa0ZTTGJ2cThrZFZRNWZncmpNcWlUWlJRSlJhY1Z3Y2szUDZSUnE1ME5hbXFEQVY0RXIvSDhyWi9EMU8KK0dlNzFUZ0JBb0dCQVBNTFJHODhxRTFhRlBWUVd5aUllK1BMeG9HWC94OVJRVmZOVENzZzgyTFZNZmRRd1FhYgpvS20zV1BUMTQzOWVQNytFenowdUN0NDBON3pMa0ZYUEtuRFc3MldjSjdGa3NzdHFMSnRzbVIvL2dzbEFpVi9SCnVrcjRoaGN0U1hmTzJmKzFBa2lDc0VRT3lqWHgwYzNEcXpTVWNvOVRzSWl4L0JKSDlGRVFHeENUQW9HQkFPUnYKWnJZdjAxcmZXaU5xbE4yN2d4R1AvKzY2c3pjelJHcGRLcENIbDg2WHdqQVdrVWZzYXZIRWl1S1RaaisycUlMVQpLMmxwNlYvdDd0bkJhakdnQ2lWeVNtdEU4cXdlRTNZZk8remx3Y3AwQlVDQVpsMzlYbkR6cHVJSGhOKzRWWUk5CjZ4bnFxdkhyL2tzWUxkWTJzRWk4NWlrQTZNRUdLTytORzhCQlU2QjVBb0dCQUo3ek5uMTljU0N0a2xsaGhVeTcKL2pKYnVlWlZicytmaDVtUnRZZmJVL0hHTnBobFl1Z2NiZld3NkdmRVRGV25ZUSt6SHdvSEM2cUpBZzdpSHZKUAp1NVR5ckx5S1pOYzZZVWh4bHR6TEtGWHArRElBbUJkbmhXdTBuNVdXMDU2Y1ZLeE1TRUw5M2FPVS9LQk5GNFozCnVvZDNzbmlVSmpjd0dBZ29zTnMzS2t3ckFvR0JBSnpXYjZxK2cxcHM1ekpSeHd2RjVtTjBmcitscDg1S2dMcVcKWk5iK2daZnlVZjA2UVYwa1VQalZmSlc3cGdRd29OblNXa3Z4ejYxeGF3Qk83MTVMQnl4V29BbXVPUDg3VnhsTwpzSkloM1QvbkVJUU1wRHY3N1krWGVnak9LTWlCZ3hQODl5SEFJTVlneFdOQm9wYmt6WHZqVmhMbzhPVTJHWHovCllRSksxK1BoQW9HQVkvYUtJYU9TY2xaN2J6ZjhVNWFTbFdtMzg2MlRxZGRRUCtGdDNnUXVjSmZzM1orTnlXbzcKZW9oU2E2UXl3U3p5LzJzV0VhVUxzR1BvcnkvdGRYOEhnM1ZyUndwdXNyK3JxeURvNDBRYzN0aEVPd2FsL21FWgpKVkc5R3E1dWFhK2FwbGpIa2U1NkRZaHdISk1relNIakVGMDlKeFZvYWU4V2hqVk43UTNBYjdJPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
  # End optional secret for TLS certs
  ---
  apiVersion: apps/v1beta2
  kind: Deployment
  metadata:
    labels:
      app: hello-world
    name: hello-world
    namespace: default
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: hello-world
    strategy:
      rollingUpdate:
        maxSurge: 1
        maxUnavailable: 0
      type: RollingUpdate
    template:
      metadata:
        labels:
          app: hello-world
      spec:
        containers:
        - image: rancher/hello-world
          imagePullPolicy: Always
          name: hello-world
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              port: 80
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 2
            successThreshold: 1
            timeoutSeconds: 2
          ports:
          - containerPort: 80
            protocol: TCP
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: hello-world
    namespace: default
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 80
    selector:
      app: hello-world
  ---
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: hello-world
    namespace: default
  spec:
    rules:
    - host: hello-world.mycompany.io
      http:
        paths:
        - backend:
            serviceName: hello-world
            servicePort: 80
    # Optional tls ingress section
    tls:
    - hosts:
      - hello-world.mycompany.io
      secretName: mycompany-io
    # End of optional tls ingress section
  ```

  - At rancher ui, go to `Workload` page on your rancher project, and click on `Import YAML` button.

  Paste you deployment manifest or click `Read from file` button.

  <img src="../img/import_deployment.png" width="800" alt="Import workload">

  - Once all is deployed, at workload view you should see new service entrypoint. Clicking on it, service site will be opened at `http://hello-world.mycompany.io` or `https://hello-world.mycompany.io` depending if you use tls or not.

  <img src="../img/entrypoint_workload.png" width="800" alt="Entrypoint for workload">

  Check that `hello-world.mycompany.io` dns entry, points to your k8s cluster nodes ip's running ingress. 

### External lb L4

Optionally, you could use external lb at layer 4 to redirect request to ingress controllers. 

At this scenario, tls is still configured at ingress, rediection is done at osi layer 4, ip. Also, `hello-world.mycompany.io` dns entry, should point to external lb l4 ip's. 

<img src="../img/service-SSL_external-L4.jpg" width="800" alt="external-L4">

As external lb at layer 4, you could use some options, AWS NLB, nginx, haproxy,...

#### AWS NLB

  - Creating Target groups, one for for 80 and other for port 443, both TCP.
  
  ```
  Port 80
  Target group name: hello-world-tcp-80
  Protocol: TCP
  Port: 80
  Target type: Instance
  VPC: <YOUR_VPC>

  Health check settings
  Protocol: TCP

  Port 443
  Target group name: hello-world-tcp-443
  Protocol: TCP
  Port: 443
  Target type: Instance
  VPC: <YOUR_VPC>

  Health check settings
  Protocol: TCP
  ```

  - Once target groups are created, select them one by one and  "Action" -> "Register and deregister targets”

  ```
  hello-world-tcp-80
  Select instances that are running ingress-controller in your k8s custer, click “Add to registered” on port 80 and "save"

  hello-world-tcp-443
  Select instances that are running ingress-controller in your k8s custer, click “Add to registered” on port 443 and “save"
  ```

  - Create a network load balancer

  ```
  Name: hello-world-http-https
  Scheme: internet-facing

  IP address type: ipv4

  Listeners
  Add 2 listeners:
  80 TCP -> forwarding to hello-world-tcp-80
  443 TCP -> forwarding to hello-world-tcp-443

  Availability Zones
  Select your VPC and availability zone

  Add Target groups for every listener.

  Configure Security Settings

  Configure Security Groups

  Configure Routing
  ```

  Check that `hello-world.mycompany.io` dns entry, points to your external NLB ip's.

#### NGINX

  - Deploy and configure your external nginx lb l4 to redirect request to FQDN to ingress ip's. 

  ```
  worker_processes 4;
  worker_rlimit_nofile 40000;

  events {
      worker_connections 8192;
  }

  http {
      server {
          listen         80;
          return 301 https://$host$request_uri;
      }
  }

  stream {
      upstream hello-world_servers {
          least_conn;
          server <ingress_ip1>:443 max_fails=3 fail_timeout=5s;
          server <ingress_ip2>:443 max_fails=3 fail_timeout=5s;
      }
      server {
          listen     443;
          proxy_pass hello-world_servers;
      }
  }
  ```

  Check that `hello-world.mycompany.io` dns entry, points to your external nginx instances ip's.

Accessing to the service, `http://hello-world.mycompany.io` or `https://hello-world.mycompany.io`

<img src="../img/hello-world_site.png" width="800" alt="Accesing service">
