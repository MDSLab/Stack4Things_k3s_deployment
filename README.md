# S4T Deployment
This repository contains the complete deployment of Stack4Things, an open-source framework designed to address the complexities of IoT fleet management, on Kubernetes.

## Prerequisites

To run this project correctly, ensure to install the following dependencies using this guide:

- [K3s](#k3s-installation): A lightweight alternative to Kubernetes
- [Helm](#helm-installation): A package manager for Kubernetes
- [MetalLB](#metallb-installation): A load balancer for Kubernetes clusters
- [Istio](#istio-installation-with-helm): A service mesh for traffic management 

If you already have those dependencies, jump to [S4T installation](#s4t---stack4things-deployment)

## K3s installation
  
```bash
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```

If you find any kind of error, please refer to the official guide:

- [Quick-Start-K3s](https://docs.k3s.io/quick-start)

## Helm installation   
The [Helm project](https://helm.sh/docs/intro/install/) provides two official methods for downloading and installing Helm. In addition to these, the Helm community also provides other installation methods via various package managers.

### Script installation (recommended) 
Helm provides an installation script that automatically downloads and installs the latest version of Helm on your system.
  
You can download the script and run it locally. It is well documented, so you can read it in advance to understand what it does before running it.

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### Binary installation
Every release of Helm provides binary releases for a variety of OSes. These binary versions can be manually downloaded and installed.

- Download your [desired version](https://github.com/helm/helm/releases)
- Unpack it (tar -zxvf helm-v3.0.0-linux-amd64.tar.gz)
- Find the helm binary in the unpacked directory, and move it to its desired destination (mv linux-amd64/helm /usr/local/bin/helm)


From there, you should be able to run the client and add the stable chart repository: helm help.

## MetalLB installation
### Installation by manifest (recommended)
To install MetalLB, apply the manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
```
After the installation, if not present inside the folder ./metalLB, create a file named "metallb-config.yaml" and use the following configuration:
```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system 
spec:
  addresses:
  - 192.168.1.100-192.168.1.200 # Change pool of IPs if needed
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-config
  namespace: metallb-system
```

Then, apply this configuaration in the cluster:
```
kubectl apply -f metallb-config.yaml
```
Use those commands to verify the correct creation of the metalLB pod and service.
```
kubectl get pods -n metallb-system
kubectl get svc -A
```

## Istio installation with Helm  

#### Adding the Helm repository of Istio  
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
```

#### Updating repositories
```bash
helm repo update
```

#### Installation of the Istio base
```bash
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
>> Expected output:
- NAME: istio-base
- LAST DEPLOYED: **date**
- NAMESPACE: istio-system
- STATUS: deployed
- REVISION: 1
- TEST SUITE: None
- NOTES:
- Istio base successfully installed!
```

#### Verification of istio-base status
```bash
helm status istio-base -n istio-system
helm get all istio-base -n istio-system
helm ls -n istio-system
```
#### Installation of istiod service
```bash
helm install istiod istio/istiod -n istio-system --wait
```

#### Checking the installation
```bash
helm ls -n istio-system
helm status istiod -n istio-system
```

#### Checking the status of istiod pods
```bash
kubectl get deployments -n istio-system --output wide
>> Expected output:
NAME     READY   UP-TO-DATE   AVAILABLE   AGE  CONTAINERS  SELECTOR
istiod   1/1     1            1           23m  discovery   istio=pilot
```

#### Creating the namespace for the gateway
```bash
kubectl create namespace istio-ingress
>> Expected output: namespace/istio-ingress created
```

#### Installation of the Istio gateway
```bash
helm install istio-ingress istio/gateway -n istio-ingress --wait
```

#### Verification of services
```bash
kubectl get svc -A
>> Expected output: Istio created the LoadBalancer.
``` 

#### Verification of Istio Ingress pods  
```bash
kubectl get pods -n istio-ingress
>>Expected output:
NAME                             READY   STATUS
istio-ingress-<PodID>   1/1     Running
```

#### Verification of Istio Ingress Service
```bash
kubectl get svc -n istio-ingress
>> Expected output:
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)
istio-ingress   LoadBalancer   x.x.x.x         192.168.1.100         15021:30268/TCP,80:31240/TCP,443:32410/TCP
```

If you find any kind of error, please refer to the official guide:
- **Official Guide**: [Istio installation with Helm](https://istio.io/latest/docs/setup/install/helm/)  


## S4T - Stack4Things Deployment

This guide describes how to clone, configure and start **Stack4Things** on Kubernetes.

### 
1. Clone this repository:
```
git clone https://github.com/MDSLab/Stack4Things_k3s_deployment.git
```
2. Move to correct directory
``` 
cd Stack4Things_k3s_deployment
```
3. Apply YAML files to the Kubernetes cluster:
```bash
cd yaml_file
kubectl apply -f .
```
4. Check that the Pods are active:
```bash
kubectl get pods
```
5. Check available services:
```bash
kubectl get svc
```

### Exposing port 8181

Modify the Service for istio-ingress to include port 8181.
Run the following command to edit the existing configuration:

```
kubectl edit svc istio-ingress -n istio-ingress
```
Then, add the 8181 port under spec.ports:

```
spec:
  ports:
    - name: tcp-crossbar
      port: 8181
      targetPort: 8181
      protocol: TCP
```

Now, you need to configure Istio to handle port 8181.
Edit the deployment with:

```
kubectl edit deployment istio-ingress -n istio-ingress
```
Look for the containers → ports section and add:

```
        - containerPort: 8181
          name: tcp-crossbar
          protocol: TCP
```

Save and close.


### Creating the Gateway and VirtualService for Iotronic-UI and Crossbar

- Enter the folder where the configuration file is contained and apply the YAML file to the Kubernetes cluster:
```bash
cd istioconf
kubectl apply -f .
```

- Verify that the resources have been created correctly:
```bash
kubectl describe virtualservice iotronic-ui
kubectl describe virtualservice crossbar
```

- Check the istio-ingress service to obtain the public IP of the load balancer:
```bash
kubectl get svc istio-ingress -n istio-ingress
```
- Output expetation:
```bash
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                                                     AGE
istio-ingress   LoadBalancer   10.43.24.188   192.168.1.100   15021:32693/TCP,80:30914/TCP,443:32500/TCP,8181:30946/TCP   4d21h
```

- Verify the creation of the VirtualService:
```bash
kubectl get virtualservice
```

-  Output expetation:
```bash
NAME          GATEWAYS                  HOSTS   AGE
crossbar      ["crossbar-gateway"]      ["*"]   4d1h
iotronic-ui   ["iotronic-ui-gateway"]   ["*"]   4d21h
```

- Check the gateway:
```bash
kubectl get gateway
```

- Output expetation:
```bash
NAME                  AGE
crossbar-gateway      4d1h
iotronic-ui-gateway   4d21h
```

### Testing service access
- Use curl to test access to the Iotronic UI via the istio-ingress IP:
```bash
curl 192.168.1.100/iotronic-ui
```
Check also via browser the access to the page:
```
http://192.168.1.100:8100/horizon/auth/login/?next=/horizon/
```


## Common errors
1. **Lack of permission on "/etc/rancher/k3s/k3s.yaml" file**
```
error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied
```

- **Check Permissions:**
You can check the current permissions of the file using the ls -l command:
```
ls -l /etc/rancher/k3s/k3s.yaml
```
This will display the file's permissions. You should see something like this:

```
-rw-r--r-- 1 root root 1234 Mar 19 12:34 /etc/rancher/k3s/k3s.yaml
```

- **Change Permissions (if necessary):**
If the file is not readable by the user you're logged in as, you can either change its permissions or use sudo to access it.

To change the permissions so all users can read the file, you can run:
```
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```