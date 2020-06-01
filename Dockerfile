ARG IMAGEWEBGTW=intersystems/webgateway:2020.1.0.215.0
FROM ${IMAGEWEBGTW}
RUN /configHttpd.sh
ADD setupWebGateway.sh /
ADD certbot-setup.sh /
ADD startUpScript.sh /
RUN chmod +x setupWebGateway.sh certbot-setup.sh startUpScript.sh && /setupWebGateway.sh
RUN a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb && a2enmod headers
# ADD CSP.ini /opt/webgateway/bin/
ADD 000-default.conf /etc/apache2/sites-enabled/