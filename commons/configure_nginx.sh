#!/bin/bash 

###################################################################
#Script Name	: configure_nginx.sh                             
#Description	: userdata template script to configure kibana
###################################################################

nginx -v
if [ "$?" -ne "0" ]
then
    yum update -y
    yum install nginx -y
fi

echo "${file("../commons/nginx.conf")}" > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt \
    -subj "/C=BE/ST=Brussels/L=Brussels/O=EXAMPLE/OU=Org/CN=www.pari.com"

ES_ENDPOINT=${es_endpoint}
COGNITO_DOMAIN=${cognito_domain}

sed -i "s/_ES_endpoint/$ES_ENDPOINT/g" /etc/nginx/nginx.conf
sed -i "s/_cognito_host/$COGNITO_DOMAIN/g" /etc/nginx/nginx.conf
sed -i "s/_host/\$host/g" /etc/nginx/nginx.conf

service nginx start
chkconfig nginx on