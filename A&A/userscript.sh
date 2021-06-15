#!/bin/bash

#To take from the admin-cluster config (to modify)
certificate_data="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLSS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
server="https://x.x.x.x:6443"

#The default path for Kubernetes CA
ca_path="/etc/kubernetes/pki"

#The default name for the Kubernetes cluster
cluster_name="kubernetes"


create_user() {

	#Create the user
	printf "User creation\n"
	useradd -m $user

	#Create private Key for the user
	printf "Private Key creation\n"
	openssl genrsa -out $filename.key 2048

	#Create the CSR
	printf "\nCSR Creation\n"
	if [ $group == "None" ]; then
		openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user"
	else
		openssl req -new -key $filename.key -out $filename.csr -subj "/CN=$user/O=$group"
	fi 

	#Sign the CSR 
	printf "\nCertificate Creation\n"
	openssl x509 -req -in $filename.csr -CA $ca_path/ca.crt -CAkey $ca_path/ca.key -CAcreateserial -out $filename.crt -days $days

	#Create the .certs and mv the cert file in it
	printf "\nCreate .certs directory and move the certificates in it\n" 
	mkdir $user_home/.certs && mv $filename.* $user_home/.certs

	#Create the credentials inside kubernetes
	printf "\nCredentials creation\n"
	kubectl config set-credentials $user --client-certificate=$user_home/.certs/$user.crt  --client-key=$user_home/.certs/$user.key

	#Create the context for the user
	printf "\nContext Creation\n"
	kubectl config set-context $user-context --cluster=$cluster_name --user=$user

	#Edit the config file
	printf "\nConfig file edition\n"
	mkdir $user_home/.kube
	cat <<-EOF > $user_home/.kube/config
	apiVersion: v1
	clusters:
	- cluster:
	    certificate-authority-data: $certificate_data
	    server: $server
	  name: $cluster_name
	contexts:
	- context:
	    cluster: $cluster_name
	    user: $user
	  name: $user-context
	current-context: $user-context
	kind: Config
	preferences: {}
	users:
	- name: $user
	  user:
	    client-certificate: $user_home/.certs/$user.crt
	    client-key: $user_home/.certs/$user.key
	EOF
	
	#Change the the ownership of the directory and all the files
	printf "\nOwnership update\n"
	sudo chown -R $user: $user_home



}




response=
echo "Give the CN of the user : "
read response
if [ -n "$response" ]; then
	
	user=$response
	
	echo "Give the Group of the user (If there is no group left it blank): "
	read response
	if [ -n "$response" ];then
		group=$response
	else
		group="None"
	fi

	echo "Give the number of days for the certificate (360 days by default if you left it blank): "
	read response
	if [ -n "$response" ];then
		days=$response
	else
		days=360
	fi

	
	#Set up variables
	user_home="/home/$user"
	filename=$user_home/$user
	
	echo "------------------------------------"
	
	#Execute the function create_user
	create_user
	exit

else
	echo "Username is required"
	exit
fi

