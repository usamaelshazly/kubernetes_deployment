#!/bin/bash
#pushing dependices for kubernetes to machines
if [[ $# -ne 5 ]];then 
	echo $0: usage: ./setup-keyless.sh username 192.168.1.5 192.168.1.6 192.168.1.7 192.168.1.8
	exit 1
fi

USER=$1
cp /etc/hosts hosts
echo -e  "$2    centos-master\n$3    centos-minion1\n$4    centos-minion2\n$5    centos-minion3\n" >> hosts
#master
scp hosts $USER@$2:/tmp/hosts
scp deploy_master.sh $USER@$2:/home/$1/deploy_master.sh
scp install_packages.sh $USER@$2:/home/$1/install_packages.sh
ssh -t $USER@$2 'su - root -c  "chmod +x /home/'$1'/install_packages.sh;sh /home/'$1'/install_packages.sh;"'
ssh -t $USER@$2 'su - root -c  "chmod +x /home/'$1'/deploy_master.sh;sh /home/'$1'/deploy_master.sh;"'
sleep 30


#minion 1
scp hosts $USER@$3:/tmp/hosts
scp depoly-minions.sh $USER@$3:/home/$1/depoly-minions.sh
scp install_packages.sh $USER@$3:/home/$1/install_packages.sh
ssh -t $USER@$3 'su - root -c  "chmod +x /home/'$1'/install_packages.sh;sh /home/'$1'/install_packages.sh;"'
ssh -t $USER@$3 'su - root -c  "chmod +x /home/'$1'/depoly-minions.sh;sh /home/'$1'/depoly-minions.sh;"'
	
#minion 2
scp hosts $USER@$4:/tmp/hosts
scp depoly-minions.sh $USER@$4:/home/$1/depoly-minions.sh
scp install_packages.sh $USER@$4:/home/$1/install_packages.sh
ssh -t $USER@$4 'su - root -c  "chmod +x /home/'$1'/install_packages.sh;sh /home/'$1'/install_packages.sh;"'
ssh -t $USER@$4 'su - root -c  "chmod +x /home/'$1'/depoly-minions.sh;sh /home/'$1'/depoly-minions.sh;"'

#minion 3 
scp hosts $USER@$4:/tmp/hosts
scp depoly-minions.sh $USER@$4:/home/$1/depoly-minions.sh
scp install_packages.sh $USER@$4:/home/$1/install_packages.sh
ssh -t $USER@$4 'su - root -c  "chmod +x /home/'$1'/install_packages.sh;sh /home/'$1'/install_packages.sh;"'
ssh -t $USER@$4 'su - root -c  "chmod +x /home/'$1'/depoly-minions.sh;sh /home/'$1'/depoly-minions.sh;"'
