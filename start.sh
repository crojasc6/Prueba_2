#!/bin/bash

# Cargar las variables de credenciales
source /usr/local/nagios/etc/.env

# Anular las variables de entorno si se pasan como argumentos durante la ejecución de Docker
if [ -n "$NAGIOSADMIN_USER_OVERRIDE" ]; then
    export NAGIOSADMIN_USER="$NAGIOSADMIN_USER_OVERRIDE"
fi

if [ -n "$NAGIOSADMIN_PASSWORD_OVERRIDE" ]; then
    export NAGIOSADMIN_PASSWORD="$NAGIOSADMIN_PASSWORD_OVERRIDE"
fi

# Actualizar los archivos de configuración con los valores de las variables, considerando las anulaciones
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users "${NAGIOSADMIN_USER_OVERRIDE:-$NAGIOSADMIN_USER}" "${NAGIOSADMIN_PASSWORD_OVERRIDE:-$NAGIOSADMIN_PASSWORD}"
sed -i "s/nagiosadmin/${NAGIOSADMIN_USER_OVERRIDE:-$NAGIOSADMIN_USER}/g" /usr/local/nagios/etc/cgi.cfg

# Iniciar Nagios
/etc/init.d/nagios start

# Iniciar Apache en primer plano
a2dissite 000-default default-ssl
rm -rf /run/apache2/apache2.pid
. /etc/apache2/envvars
. /etc/default/apache-htcacheclean
/usr/sbin/apache2 -DFOREGROUND
