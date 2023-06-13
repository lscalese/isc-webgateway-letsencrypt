ARG IMAGEWEBGTW=containers.intersystems.com/intersystems/webgateway:2023.1.0.235.1
FROM ${IMAGEWEBGTW}
ADD setupWebGateway.sh /
ADD certbot-setup.sh /
ADD startUpScript.sh /
RUN chmod +x setupWebGateway.sh certbot-setup.sh startUpScript.sh && /setupWebGateway.sh
RUN a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb && a2enmod headers
ADD CSP.ini /opt/webgateway/bin/
ADD 000-default.conf /etc/apache2/sites-enabled/