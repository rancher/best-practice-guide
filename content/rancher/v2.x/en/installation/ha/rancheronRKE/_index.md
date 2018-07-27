---
title: Rancher HA on RKE
weight: 2300
draft: true
version: v2.0
lang: en
---

---

### Requirements

- rancher cli command in OS path.
- 3 linux nodes to deploy rke cluster. 
- TLS mode `external`: 
  - External LB running with SSL.
  - FQDN dns entry for rancher server pointing to external LB.
- TLS mode `ingress`: 
  - TLS key, certificate and ca files for your FQDN.
  - FQDN dns entry for rancher server pointing to rke cluster nodes running ingress.
  - TLS issuer `<blank>`: TLS key and certificate. ca cert if selfsigned ca files for your FQDN.
  - TLS issuer `ca`: CA key and cert.
  - TLS issuer `acme`: Letsencrypt email ID.

### Quick view

- Provision Linux Hosts
- Configure DNS
- Using RKE
  - Download RKE template
  - Edit RKE template (nodes and rancher HA config)
  - Up RKE cluster
- Using rancher cli (Comming soon)
  - Generate RKE template
  - Add nodes info to RKE template
  - Up RKE cluster


### Provision Linux Hosts

Before you install Rancher, confirm you meet the host requirements. Provision 3 new Linux hosts using the requirements below.

Operating System Requirements
- Ubuntu 16.04 (64-bit)
- Red Hat Enterprise Linux 7.5 (64-bit)
- RancherOS 1.3.0 (64-bit)

Hardware requirements scale based on the size of your Rancher deployment. Provision each individual node according to the requirements.

| Deployment Size | Clusters | Nodes | vCPUs | RAM |
| ---- | ---- |  ---- | ---- | ---- | 
| Small | Up to 10  | Up to 50  | 2 | 4GB |
| Medium | Up to 100 | Up to 500 | 8 | 32GB |
| Large | Over 100  | Over 500 | Contact Rancher |

Software Requirements Docker

- 1.12.6
- 1.13.1
- 17.03.02

Note:
If you are using RancherOS, make sure you switch the Docker engine to a supported version using sudo ros engine switch docker-17.03.2-ce
Supported Versions

Port Requirements on your Linux hosts.

| Protocol | Port range | Purpose |
| ---- | ---- |  ---- |
| tcp | 22 | ssh server |
| tcp | 80 | Rancher Server/ingress |
| tcp | 443 | Rancher Server/ingress |
| tcp | 6443 | kubernetes api server |
| tcp | 2379-2380 | etcd server client api |
| tcp | 10250-10256 | kubernetes components |
| tcp | 30000-32767 | nodeport services |
| udp | 8472 | canal |

### Configure DNS

Choose a fully qualified domain name (FQDN) you want to use to access Rancher (something like rancher.yourdomain.com).

You need to create a DNS A record, pointing to the IP address of your RKE nodes. If the DNS A record is created, you can validate if it’s setup correctly by running nslookup rancher.yourdomain.com. It should return the IP addresses of your RKE nodes like in the example below.

```
$ nslookup rancher.yourdomain.com
Server:         your_nameserver_ip
Address:        your_nameserver_ip#53

Non-authoritative answer:
Name:   rancher.yourdomain.com
Address: ip_of_node1
Name:   rancher.yourdomain.com
Address: ip_of_node2
Name:   rancher.yourdomain.com
Address: ip_of_node3
```

### Using RKE

#### Download RKE template

RKE uses a .yml manifest file to install and configure your k8s cluster. There are 4 templates to choose from, depending on the SSL certificate you want to use and `tls-mode`

Download one of following templates:

`tls-mode ingress`
- Using Self Signed Certificate [3-node-certificate.yml](https://github.com/rancher/rancher/blob/master/rke-templates/3-node-certificate.yml)
- Using Certificate Signed By Recognized CA [3-node-certificate-recognizedca.yml](https://github.com/rancher/rancher/blob/master/rke-templates/3-node-certificate-recognizedca.yml)

`tls-mode external`
- Using Self Signed Certificate [3-node-externalssl-certificate](https://github.com/rancher/rancher/blob/master/rke-templates/3-node-externalssl-certificate.yml)
- Using Certificate Signed By Recognized CA [3-node-externalssl-recognizedca.yml](https://github.com/rancher/rancher/blob/master/rke-templates/3-node-externalssl-recognizedca.yml)
- Rename template to `rancher-cluster.yml`.

#### Edit RKE template

- Edit `rancher-cluster.yml` template 
  - configure nodes section setting following placeholders
    - `<IP>`: The IP address or hostname of the node.
    - `<USER>`: The username to use to setup a SSH connection to the node. If the user is not the root user, make sure the user has access to the Docker socket. This can be tested by logging in on the node as the configured user and run docker ps.
    - `<SSHKEY_FILE>`: The path of the SSH private key file used to authenticate to the node.
  - If `tls-mode ingress`, configure addons section setting following placeholders
     - `<BASE64_CRT>`: the base64 encoded string of the Certificate file (usually called cert.pem or domain.crt)
     - `<BASE64_KEY>`: the base64 encoded string of the Certificate Key file (usually called key.pem or domain.key)
     - `<BASE64_CA>`: the base64 encoded string of the CA Certificate file (usually called ca.pem or ca.crt)
     - `<FQDN>`: the FQDN chosen in Configure DNS.
- Backup RKE template

#### Up RKE cluster

All configuration is in place to run RKE. Be sure you have installed it at you workstation. 
- Open a web browser and navigate to our [RKE Releases page](https://github.com/rancher/rke/releases/latest) 
- Download the latest RKE binary for your platform, `rke_linux-amd64`, `rke_darwin-amd64` or `rke_windows-amd64.exe`.
- Rename file to `rke` and move it to some folder in your PATH.

- To deploy RKE cluster and rancher HA as addons, just run:

```
rke up --config rancher-cluster.yml
```

- RKE will generate a `kubectl` config file named `kube_config_rancher-cluster.yml`. Backup this file, it will be use to connect to new RKE k8s cluster and upgrade rancher. 


### Using rancher cli (Comming soon)

#### Generate RKE template

- Generate a minimal RKE rancher HA template. Execute:
  - tls-mode ingress: Ingress as SSL termination
    - Public CA
    
    ```
    rancher ha template --hostname <FQDN> --tls-key <KEY_FILE> --tls-cert <CERT_FILE>
    ```

    - Selfsigned CA
    
    ```
    rancher ha template --hostname <FQDN> --tls-key <KEY_FILE> --tls-cert <CERT_FILE> --tls-ca-cert <CA_CERT_FILE>
    ```

    - CA integrated `--tls-issuer ca` (Using cert-manager)
    
    ```
    rancher ha template --hostname <FQDN> --tls-mode ingress --tls-ca-cert <CA_CERT_FILE> --tls-ca-key <CA_KEY_FILE> --tls-issuer ca --output-mode k8s
    ```

    - CA integrated and default ingress cert `--tls-issuer ca` (Using cert-manager)
    
    ```
    rancher ha template --hostname <FQDN> --tls-mode ingress --tls-ca-cert <CA_CERT_FILE> --tls-ca-key <CA_KEY_FILE> --tls-issuer ca --tls-issuer-default
    ```

    - Letsencrypt integrated `--tls-issuer acme` - staging (Using cert-manager)
    
    ```
    rancher ha template --hostname <FQDN> --tls-mode ingress --tls-issuer acme --tls-acme-email <EMAIL>
    ```

    - Letsencrypt integrated `--tls-issuer acme` - production (Using cert-manager)
    
    ```
    rancher ha template --hostname <FQDN> --tls-mode ingress --tls-issuer acme --tls-acme-email <EMAIL> --tls-acme-prod
    ```

  Note: If `--tls-issuer ca` or `--tls-issuer acme` cert-manager will be included as addon at RKE template. 

  - tls-mode rancher: Rancher as SSL termination
  
    ```
    rancher ha template --hostname <FQDN> --tls-mode rancher
    ```

  - tls-mode external: External LB as SSL termination (Assumed external LB are working with FQDN)
    - Public CA 

    ```
    rancher ha template --hostname <FQDN> --tls-mode external
    ```

    - Selfsigned CA 
    
    ```
    rancher ha template --hostname <FQDN> --tls-mode external --tls-ca-cert <CA_CERT_FILE>
    ```

- RKE rancher HA template `rancher_HA.yml` will be generated

#### Add nodes info to RKE template

- Edit `rancher_HA.yml` template 
- configure nodes section setting following placeholders
  - `<IP>`: The IP address or hostname of the node.
  - `<USER>`: The username to use to setup a SSH connection to the node. If the user is not the root user, make sure the user has access to the Docker socket. This can be tested by logging in on the node as the configured user and run docker ps.
  - `<SSHKEY_FILE>`: The path of the SSH private key file used to authenticate to the node.
- Backup RKE template

#### Up RKE cluster

- To deploy RKE cluster and rancher HA as addons, just run:

```
rancher ha up -f rancher_HA.yml -o rancher-cluster.yml
```

- Rancher cli will generate a RKE deployment manifest `rancher-cluster.yml` and a `kubectl` config file named `kube_config_rancher-cluster.yml`. Backup both files, they will be use to connect to new RKE k8s cluster and upgrade rancher.

### Checking output and accessing service

Output should be similar to 

```
INFO[0000] Building Kubernetes cluster
INFO[0000] [dialer] Setup tunnel for host [X.X.X.X]
INFO[0000] [network] Deploying port listener containers
INFO[0000] [network] Pulling image [alpine:latest] on host [X.X.X.X]
...
INFO[0103] RKE cluster deployed successfully
RKE cluster config file - rke_ingress_rancher_HA.yml
K8S config file - kube_config_rke_ingress_rancher_HA.yml
Rancher URL https://<FQDN>
```

RKE or k8s cluster will publish rancher UI on all nodes running ingress-controller and host header FQDN. 

Rancher UI should be available at `https://FQDN`


  

