# Samples webgateway with letsencrypt

This is a sample for run docker webgateway using https protocol with:  

* [letsencrypt certificate](https://letsencrypt.org/).  
* [Certbot tools](https://certbot.eff.org/).    


## Prerequisites

A server and a fully qualified domain name (we use example.com in this document).  

# Build image

Download webgateway image on WRC and load image on your docker instance : 

```
docker load -i <webgateway image file>
```

The current webgateway image is intersystems/webgateway:2020.1.0.215.0  
Adapt the Dockerfile first line with the correct webgateway image if needed. 

```
ARG IMAGEWEBGTW=intersystems/webgateway:2020.1.0.215.0
```


```
docker build --no-cache -t ssl-webgateway:latest .
```

## Push to registry

If you have your own registry, push the image.  

```
docker login <url>
docker tag ssl-webgateway:latest <host>:<port>/ssl-webgateway:latest
docker push <host>:<port>/ssl-webgateway:latest
```

# Run the webgateway

On your server.  

## Create volumes

It needs two volumes.  One for webgateway configuration files and another for letsecnrypt certificate.  
It's important to keep your certifacte outside the container.  
Do not generate a new certificate for each run otherwise You will reach the rate limit quickly.  
[See this documentation for more informations](https://letsencrypt.org/docs/rate-limits/).  

```
docker volume create webgateway
docker volume create letsencrypt
```

## Edit your docker-compose.yml file

Adapt the following example with your domain name and e-mail.

```
version: '3.6'
services:
  ssl-webgateway:
    image: <host>:<port>/ssl-webgateway:latest
    container_name: ssl-webgateway
    ports: 
      - "80:80"
      - "443:443"
    environment:
      - ISC_DATA_DIRECTORY=/durable/webgateway
      - APACHE_SERVER_ADMIN=webmaster@example.com
      - APACHE_SERVER_NAME=example.com
      - APACHE_SERVER_ALIAS=www.example.com
      - LETSENCRYPT_WEBROOT=/var/www/example
      - "LETSENCRYPT_DOMAIN=-d example.com -d www.example.com"
      - "LETSENCRYPT_ARGS=--test-cert"
    volumes:
      - "webgateway:/durable"
      - "letsencrypt:/etc/letsencrypt/live"
    command: ["sh /certbot-setup.sh"]
  iris:
    image: intersystemsdc/iris-community:2020.2.0.196.0-zpm
volumes:
  webgateway:
    external: true
    name: "webgateway"
  letsencrypt:
    external: true
    name: "letsencrypt"
```

The line  `LETSENCRYPT_ARGS=--test-cert` allow to get a certificate from a letsencrypt test server.  
It's very useful to avoid [reach the rate limit](https://letsencrypt.org/docs/rate-limits/) due too many try.  
When you are ready, simply edit this line with this value `LETSENCRYPT_ARGS=`.  
Using a certificate from a letsencrypt test server cause a browser security alert.  

## Run the containers

```
docker-compose up -d
```

Check the logs  

```
docker logs ssl-webgateway
```

Test your configuration : 
```
https://www.ssllabs.com/ssltest/analyze.html?d=example.com
https://www.ssllabs.com/ssltest/analyze.html?d=www.example.com
```

If everything is fine, you should open the management portal with `https://www.example.com/csp/sys/utilhome.csp`.

## Links

[Certbot](https://certbot.eff.org/)  
[letsencrypt](https://letsencrypt.org/)
