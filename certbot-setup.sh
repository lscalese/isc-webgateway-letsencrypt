#!/bin/bash

mkdir -p $LETSENCRYPT_WEBROOT

CONF_FILE=/etc/apache2/sites-enabled/000-default.conf

# Removed because there is a bug with letsencrypt sed will be used to fix and write directly in CONF_FILE...
# ENVVARSFILE=/etc/apache2/envvars
# echo "export APACHE_SERVER_ALIAS=$APACHE_SERVER_ALIAS" >> $ENVVARSFILE
# echo "export APACHE_SERVER_ADMIN=$APACHE_SERVER_ADMIN" >> $ENVVARSFILE
# echo "export APACHE_SERVER_NAME=$APACHE_SERVER_NAME" >> $ENVVARSFILE

sed -i '31 a ServerAdmin '$APACHE_SERVER_ADMIN $CONF_FILE
sed -i '32 a ServerName '$APACHE_SERVER_NAME $CONF_FILE
sed -i '33 a ServerAlias '"$APACHE_SERVER_ALIAS" $CONF_FILE

# certbot need apache is started
service apache2 start

certbot --apache --agree-tos --non-interactive $LETSENCRYPT_ARGS --email $APACHE_SERVER_ADMIN -w $LETSENCRYPT_WEBROOT $LETSENCRYPT_DOMAIN

# Redirect http request to https

sed -i '34 a RewriteEngine on' $CONF_FILE
sed -i '35 a RewriteCond %{SERVER_NAME} ='$APACHE_SERVER_NAME $CONF_FILE
sed -i '36 a RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]' $CONF_FILE

service apache2 restart