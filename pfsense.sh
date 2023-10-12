#!/bin/bash
host="ipaddress"
username="username"
password="password"
certificate="certificate.pem"
privatekey="privatekey.pem"

mv $certificate $certificate.combo
csplit -f $certificate.part $certificate.combo '/-----BEGIN CERTIFICATE-----/' '{*}'

for file in $certificate.part*;
do echo "Processing $file file..";
output=$(openssl x509 -noout -subject -in $file);
if [[ $output = *CN*=*.* ]]
then
        mv $file certificate.pem
fi
if [[ $output = *Authority* ]]
then
        mv $file CA_LetsEncrypt.pem
fi
done

cert=$(base64 $certificate)
cert=$(echo $cert | sed "s/ //g")
key=$(base64 $privatekey)
key=$(echo $key | sed "s/ //g")

sshpass -p $password scp $username@$host:/conf/config.xml config.xml
oldcertificate=$(grep -A4 -P 'WebConfCA' config.xml | awk '/<crt>/ { print $1}' | sed "s|<crt>||g" | sed "s|</crt>||g")
oldprivatekey=$(grep -A4 -P 'WebConfCA' config.xml | awk '/<prv>/ { print $1}' | sed "s|<prv>||g" | sed "s|</prv>||g")

if grep "$cert" config.xml > /dev/null
then
    echo "Identical certificate found, renewal not required"
else
    echo "Certificate not found, renewal required"
    sed -i -e "s|$oldcertificate|$cert|g" config.xml
    sed -i -e "s|$oldprivatekey|$key|g" config.xml
    sshpass -p $password scp config.xml $username@$host:/conf/config.xml
    sshpass -p $password ssh $username@$host rm /tmp/config.cache
    sshpass -p $password ssh $username@$host /etc/rc.restart_webgui
    find . -size  0 -name $certificate.part* -print0 |xargs -0 rm --
    rm $certificate.combo
    rm certificate.pem
    rm privatekey.pem
    rm CA_LetsEncrypt.pem
    rm config.xml
fi