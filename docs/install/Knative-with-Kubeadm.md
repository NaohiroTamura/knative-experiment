# Knative Install on Kubeadm

## Install Kubernetes

### Ubuntu 16.04

```sh
apt-get update && apt-get install -y linux-image-$(uname -r) apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update && apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

kubeadm config images pull

# change --apiserver-advertise-address to your IP address, --pod-network-cidr=192.168.0.0/16 is fixed in case of Calico
kubeadm init --ignore-preflight-errors=all --apiserver-advertise-address=10.112.136.154 --pod-network-cidr=192.168.0.0/16

kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml

kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl get pods --all-namespaces
```

## Install Istio

```sh
curl -L https://raw.githubusercontent.com/knative/serving/v0.1.1/third_party/istio-0.8.0/istio.yaml \
 | sed 's/LoadBalancer/NodePort/' \
 | kubectl apply -f -
 
# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
  
kubectl get pods -n istio-system
```

## Install Knative

```sh
curl -L https://github.com/knative/serving/releases/download/v0.1.1/release-lite.yaml \
 | sed 's/LoadBalancer/NodePort/' \
 | kubectl apply -f -
  
kubectl get pods -n knative-serving
kubectl get pods -n knative-build
```

## Configuring outbound network access

```sh
root@k8s-all-in-one:~# grep service-cluster-ip-range /etc/kubernetes/manifests/*
/etc/kubernetes/manifests/kube-apiserver.yaml:    - --service-cluster-ip-range=10.96.0.0/12

root@k8s-all-in-one:~# grep cluster-cidr /etc/kubernetes/manifests/*
/etc/kubernetes/manifests/kube-controller-manager.yaml:    - --cluster-cidr=192.168.0.0/16
```

```sh
root@k8s-all-in-one:~# kubectl edit configmap config-network -n knative-serving
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  istio.sidecar.includeOutboundIPRanges: '10.96.0.0/12,192.168.0.0/16'
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"istio.sidecar.includeOutboundIPRanges":"*"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"config-network","namespace":"knative-serving"}}
  creationTimestamp: 2018-08-19T01:37:50Z
  name: config-network
  namespace: knative-serving
  resourceVersion: "2342"
  selfLink: /api/v1/namespaces/knative-serving/configmaps/config-network
  uid: 7ba0dd4b-a350-11e8-842a-0242351e7d38
```
