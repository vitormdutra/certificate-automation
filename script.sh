#!/bin/bash

for i in "$@"
do
case $i in
    -pf=* | --path-from=*)
    PATH_FROM="${i#*=}"
    shift
    ;;
    -pt=* | --path-to=*)
    PATH_TO="${i#*=}"
    shift
    ;;
    -c=* | --connection=*)
    CONNECTION="${i#*=}"
    shift
    ;;
    -t=* | --type=*)
    TYPE="${i#*=}"
    shift
    ;;
    -u=* | --user=*)
    USER="${i#*=}"
    shift
    ;;
    -n=* | --node=*)
    NODE="${i#*=}"
    shift
    ;;
    *)

    ;;
esac
done

if [ "x$CONNECTION" = "x" ]; then
    echo "Not found URL to access machine"
    exit 1
fi


if [ "$TYPE" = "proxmox" ]; then 
    ssh $USER@$CONNECTION -t 'mv /etc/pve/'${NODE}'/pve-ssl.pem /etc/pve/'${NODE}'/pve-ssl.old'
    ssh $USER@$CONNECTION -t 'mv /etc/pve/'${NODE}'/pve-key.pem /etc/pve/'${NODE}'/pve-key.old'
    scp -r $PATH_FROM $USER@$CONNECTION:$PATH_TO
    ssh $USER@$CONNECTION -t 'mv '${PATH_TO}'/fullchain.pem /etc/pve/'${NODE}'/pve-ssl.pem'
    ssh $USER@$CONNECTION -t 'mv '${PATH_TO}'/privkey.pem /etc/pve/'${NODE}'/pve-key.pem'
    ssh $USER@$CONNECTION -t 'systemctl restart pveproxy'
fi

#if [ "$TYPE" = "pfsense" ]; then 

#fi

if [ "$TYPE" = "linux" ]; then 
    scp -r $PATH_FROM $USER@$CONNECTION:$PATH_TO
fi