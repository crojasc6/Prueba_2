#!/bin/bash
set -e

# Cargar variables del entorno
if [ -f /usr/local/nagios/etc/.env ]; then
    source /usr/local/nagios/etc/.env
fi

# Anular con variables de entorno si están definidas
NAGIOSADMIN_USER="${NAGIOSADMIN_USER_OVERRIDE:-$NAGIOSADMIN_USER}"
NAGIOSADMIN_PASSWORD="${NAGIOSADMIN_PASSWORD_OVERRIDE:-$NAGIOSADMIN_PASSWORD}"

# Configurar autenticación para interfaz web
if [ -n "$NAGIOSADMIN_USER" ] && [ -n "$NAGIOSADMIN_PASSWORD" ]; then
    htpasswd -b -c /usr/local/nagios/etc/htpasswd.users "$NAGIOSADMIN_USER" "$NAGIOSADMIN_PASSWORD"
    sed -i "s/nagiosadmin/$NAGIOSADMIN_USER/g" /usr/local/nagios/etc/cgi.cfg
fi

# Redirigir raíz a /nagios en Apache
if ! grep -q "RedirectMatch ^/\$ /nagios" /etc/apache2/apache2.conf; then
    echo 'RedirectMatch ^/$ /nagios' >> /etc/apache2/apache2.conf
fi

# Asegurar que Nagios se inicie
service nagios start

# Configurar Apache
a2dissite 000-default default-ssl || true
rm -f /run/apache2/apache2.pid
. /etc/apache2/envvars

# Iniciar Apache en primer plano
exec apache2 -DFOREGROUND

