
#on master
apt install kubectl -y
#kubeadm init --pod-network-cidr=10.244.0.0/16 >> cluster_initialized.txt
kubeadm init --pod-network-cidr=192.168.0.0/16 >> cluster_initialized.txt
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
systemctl restart kubelet.service
kubeadm token create --print-join-command

