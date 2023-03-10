### Initialize the Kubernetes cluster in Master Node
```sh
IPADDR="10.0.101.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"
K8S_VERSION="1.26.2"
sudo kubeadm init \
  --apiserver-advertise-address=$IPADDR \
  --apiserver-cert-extra-sans=$IPADDR \
  --pod-network-cidr=$POD_CIDR \
  --node-name $NODENAME \
  --ignore-preflight-errors Swap \
  --kubernetes-version $K8S_VERSION
```
### In the master node, run the following to get the config to the right place
```sh
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### In the agent node, run the following to join the cluster
```sh
kubeadm join <<MASTER_NODE>>:6443 --token <<TOKEN>> \
	--discovery-token-ca-cert-hash sha256:<<CA_CERT_HASH>> 
```