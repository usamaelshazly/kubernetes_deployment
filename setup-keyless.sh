#!/bin/bash
if [[ $# -ne 5 ]];then 
	echo $0: usage: ./setup-keyless.sh username 192.168.1.5 192.168.1.6 192.168.1.7 192.168.1.8
	exit 1
fi
USER=$1
cd ..
echo "create authentication ssh-keygen keys on localhost"
echo "will set up keys on $2, $3, $4, $5"

ssh-keygen -t rsa

for computer in  ${@:2}
do
if ping -q -c 1 -W 1 $computer >/dev/null; then
  echo " $computer  is up setting ssh settings"
  echo "create .ssh directory on $computer"
  ssh -q $USER@$computer mkdir -p .ssh
  echo "upload generated public keys to remove hosts"
  cat .ssh/id_rsa.pub | ssh $USER@$computer 'cat >> .ssh/authorized_keys'
  echo "set permissions on authorized_keys folder"
  ssh $USER@$computer "chmod 700 .ssh; chmod 640 .ssh/authorized_keys"
  echo "test logon on remote machines"
  ssh $USER@$computer hostnamectl
else
  echo " $computer is down"
fi
done




