#!/bin/bash
#edit KUBE_MASTER
echo "configuring kubemaster settings""
sed -i s/127.0.0.1/centos-master/g /etc/kubernetes/config

#edit KUBE_ETCD_SERVERS 
echo "cobnfiguring etcd settings"
echo KUBE_ETCD_SERVERS="—etd-servers=http://centos-master:2379" >> /etc/kubernetes/config
#update etcd settings
sed -i s/localhost/0.0.0.0/g /etc/etcd/etcd.conf 

#setting up api server
echo "configuring api server"
sed -i s/--insecure-bind-address=127.0.0.1/--address=0.0.0.0/g /etc/kubernetes/apiserver
sed -i s/#.*K/K/g /etc/kubernetes/apiserver
sed -i s/KUBE_ADMISSION_CONTROL/#KUBE_ADMISSION_CONTROL/g /etc/kubernetes/apiserver 

#enabling services
print "enabling services"
systemctl enable etcd kube-apiserver kube-controller-manager kube-scheduler
Starting services
systemctl start etcd kube-apiserver kube-controller-manager kube-scheduler

#checking status of services 
print "checking status of services"
COUNT=$(systemctl status etcd kube-apiserver kube-controller-manager kube-scheduler | grep active | wc -l)

if [ $COUNT == "4" ]; then
        echo “All four services are active”
else
        echo “check services”
fi