# Sample webgateway with letsencrypt

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
It's important to keep your certificate outside the container.  
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
    image: ssl-webgateway:latest
    container_name: ssl-webgateway
    ports: 
      - "80:80"
      - "443:443"
    environment:
      - ISC_DATA_DIRECTORY=/durable/webgateway
      - IRIS_USER=CSPsystem
      - IRIS_PASSWORD=SYS
      - IRIS_HOST=iris
      - IRIS_PORT=51773
      - IRIS_WEBAPPS=/irisapp1 /irisapp2 /irisapp3
      - APACHE_SERVER_ADMIN=webmaster@example.com
      - APACHE_SERVER_NAME=example.com
      - APACHE_SERVER_ALIAS=www.example.com
      - LETSENCRYPT_WEBROOT=/var/www/example
      - LETSENCRYPT_DOMAIN=-d example.com -d www.example.com
      - LETSENCRYPT_ARGS=--test-cert
    volumes:
      - "webgateway:/durable"
      - "letsencrypt:/etc/letsencrypt"
    command: ["sh /startUpScript.sh"]
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


| Variables | Description | Example Value | 
|:--|:--|--:|
| ISC_DATA_DIRECTORY | webgateway durable location for config files | ``/durable/webgateway`` |
| IRIS_USER | Iris user for connect webgateway to iris (default is CSPsstem) | ``CSPsystem`` |
| IRIS_PASSWORD | password related to IRIS_USER | ``SYS`` |
| IRIS_HOST | Hostname or IP address of your Iris Instance | ``iris`` |
| IRIS_PORT | Iris instance port | ``51773`` |
| IRIS_WEBAPPS | By default web app name starting by /csp, /api, /isc, /swagger-ui are routed to iris. You can specify additional web apps if needed | ``/irisapp1 /irisapp2`` |
| APACHE_SERVER_ADMIN | email admin, used for setup /etc/apache2/site-enabled/000-default.conf | ``webmaster@example.com`` |
| APACHE_SERVER_NAME | Shoud be set your domain name | ``example.com`` |
| APACHE_SERVER_ALIAS | Alias for your server | ``www.example.com`` |
| LETSENCRYPT_WEBROOT | Letsencrypt webroot-path (usually /var/www/<domain name>) | ``/var/www/example`` |
| LETSENCRYPT_DOMAIN | Domain coverage for letsencrypt certificate | ``-d example.com -d www.example.com`` |
| LETSENCRYPT_ARGS | Additional argument provided to the certbot command line.  ``--test-cert`` for using a letsencrypt test server and\or ``--expand`` for expand an existing certifiate with additional domain names.   | ``--test-cert --expand`` |

If you want manage your CSP.INI and CSP.CONF yourself do not specify value for the following variables : IRIS_USER, IRIS_PASSWORD, IRIS_HOST, IRIS_PORT, IRIS_WEBAPPS.  

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


If you have an error page
```
Web Gateway Version 2020.1.0.215.0
Server Availability Error

Server is currently unavailable 
```

Try to reset the password for CSPsystem to SYS  
Open a terminal session in your webgateway container and edit CSP.ini file:  

```
docker exec -it ssl-webgateway bash
vim /durable/webgateway/webgateway/CSP.ini
```

Set the line password with value `SYS`  
```
Password=SYS
```
Save and retry.  

## Links

[Certbot](https://certbot.eff.org/)  
[Certbot command line documentation](https://certbot.eff.org/docs/using.html#apache)  
[letsencrypt](https://letsencrypt.org/)  
[Apache documentation](https://httpd.apache.org/docs/current/)
