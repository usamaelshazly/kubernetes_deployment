#!/bin/bash
if [[ $# -ne 1 ]]; then
    echo "Please see usage"
    echo  "USAGE: ./configure_workers.sh username"
    echo  "USAGE EXAMPLE: ./configure_workers.sh admin"
    exit $1
fi
USERNAME=$1

#THANKS: https://www.linuxjournal.com/content/validating-ip-address-bash-script
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function testworkernode() {
    MACHINENAME=$(ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  $1@$2 hostname)
    echo "HOSTNAME: ${MACHINENAME}"
    ping -q -c5 $MACHINENAME > /dev/null
    RESULT=$?
    if [ $RESULT -eq 0 ]
    then
       echo "ok"
    else
        sudo -- sh -c 'echo "'$2'    '${MACHINENAME}'" >> /etc/hosts'
        sudo cat /etc/hosts
    fi
}

COMMANDTOUSE=$(cat /tmp/kubeadminit.log | grep -i "kubeadm join" -A11 | tr --delete '\\\\\\\\')
echo -e '#!/bin/bash \nsudo '${COMMANDTOUSE}'' >  /tmp/addworker.sh

WORKERSFILE=$(find ~ -name  workers)
CHECKIPS=$(cat $WORKERSFILE)
for  worker in $CHECKIPS
do
    if valid_ip $worker; then
        echo "worker: $worker"
        testworkernode  "${USERNAME}" "${worker}"
        scp ./ubuntu/configure_docker.sh ${USERNAME}@${worker}:/tmp/configure_docker.sh
        scp ./ubuntu/kubeadmin.sh ${USERNAME}@${worker}:/tmp/kubeadmin.sh
        ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  ${USERNAME}@${worker} "sh /tmp/configure_docker.sh" || exit $?
        ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  ${USERNAME}@${worker} "sh /tmp/kubeadmin.sh" || exit $?
        scp ./ubuntu/configure_firewall_ports.sh ${USERNAME}@${worker}:/tmp/configure_firewall_ports.sh
        ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  ${USERNAME}@${worker} "/tmp/configure_firewall_ports.sh worker" || exit $?
        scp  /tmp/addworker.sh ${USERNAME}@${worker}:/tmp/addworker.sh
        ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  ${USERNAME}@${worker} "sh /tmp/addworker.sh" || exit $?
        MACHINENAME=$(ssh  -o PasswordAuthentication=no -o ConnectTimeout=10 -t  ${USERNAME}@${worker} hostname  2>&1) || exit $?
        NEWNAME=$(echo $MACHINENAME | awk '{print $1}'| tr -d '\r' | sed -e 's/^"//' -e 's/"$//')
        kubectl label node $NEWNAME node-role.kubernetes.io/worker=worker || exit $?
        sleep 3s
        kubectl get nodes
    fi
done
