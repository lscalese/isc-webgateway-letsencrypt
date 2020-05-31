#!/bin/bash

\printf '<Location /csp>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
\printf '<Location /api>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
\printf '<Location /isc>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
\printf '<Location /swagger-ui>\n   CSP On \n   CSPFileTypes *\n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf

ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime

apt-get update && apt-get install -y links iputils-ping software-properties-common
add-apt-repository -y ppa:certbot/certbot && apt update && apt install -y certbot python3-certbot-apache
rm /opt/webgateway/bin/CSP.ini
a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb