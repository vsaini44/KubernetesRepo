Following scripts allows you to setup three node kubernetes cluster easily.

Prerequisite
#################

1) Three ubuntu servers with atleast 2vcpu's core on them.
2) Ubuntu 16.04 TLS

Steps
#################
1) Login into all three servers and download the  install_all.sh script.
2) Run it using 'bash install_all.sh'
	> The script will setup docker repository and will install docker-ce packages \n.
	> The script will setup kubernetes repository and will install required kubernetes packages \n.
	

3) Download the install_master.sh on the master node and execute the same using 'bash install_master.sh' 
	> The script will initilize the cluster with default pod network CIDR.
	> The script will create the login access for admin user to login from the master.
	> The script will also apply flannel CNI for overlay network connectivity between the cluster nodes.
	> Finally the kubelet service will be restarted.
	> The final command will print the command to add the worker nodes in the cluster.
	

4) Copy the last command output and run the exact command on the worker nodes to get them joined into the cluster.
5) Once the command is executed, verify the cluster state using 'kubectl get nodes' on the master.
