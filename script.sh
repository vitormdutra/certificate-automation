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
    *)

    ;;
esac
done

if [ "x$CONNECTION" = "x" ]; then
    echo "Not found URL to access machine"
    exit 1
fi


if [ "$TYPE" = "proxmox" ] then 
    #COMMANDS IN PROXMOX
fi

if [ "$pro" = "pfsense" ] then 
    #COMMANDS IN PFSENSE
fi

if [ "$TYPE" = "linux" ] then 
    scp -r $PASSWORD_FROM $USER@$CONNECTION:$PATH_TO
fi