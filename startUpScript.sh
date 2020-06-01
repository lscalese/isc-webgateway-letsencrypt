#!/bin/bash

CSPCONFFILEDIR=${ISC_DATA_DIRECTORY:-/etc/apache2/mods-enabled}
CSPINIFILEDIR=${ISC_DATA_DIRECTORY:-/opt/webgateway/bin}

CSPINIFILE=${CSPCONFFILEDIR}/webgateway/CSP.ini
CSPCONFFILE=${CSPCONFFILEDIR}/webgateway/CSP.conf

if [ ! "$IRIS_HOST" = "" ]
then
    sed -i '/Ip_Address=/c\Ip_Address='$IRIS_HOST $CSPINIFILE
fi

if [ ! "$IRIS_PORT" = "" ]
then
    sed -i '/TCP_Port=/c\TCP_Port='$IRIS_PORT $CSPINIFILE
fi

if [ ! "$IRIS_USER" = "" ]
then
    sed -i '/Username=/c\Username='$IRIS_USER $CSPINIFILE
fi

if [ ! "$IRIS_PASSWORD" = "" ]
then
    sed -i '/Password=/c\Password='"$IRIS_PASSWORD" $CSPINIFILE
fi

for webapp in $IRIS_WEBAPPS
do
    
    if ! grep -q $webapp "$CSPCONFFILE"
    then
        echo "Add webapp $webapp to $CSPCONFFILE"
        \printf '<Location '$webapp'>\n   CSP On \n   CSPFileTypes *\n   SetHandler csp-handler-sa\n</Location>\n' >> $CSPCONFFILE
    else
        echo "Webapp $webapp already exist in $CSPCONFFILE"
    fi
done


echo "Start script certbot-setup.sh..."
. /certbot-setup.sh

