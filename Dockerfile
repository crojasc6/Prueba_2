FROM ubuntu:24.04

RUN apt update -y

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    autoconf \
    gcc \
    libc6 \
    make \
    wget \
    unzip \
    apache2 \
    apache2-utils \
    php \
    libapache2-mod-php \
    libgd-dev \
    libssl-dev \
    libmcrypt-dev \
    bc \
    gawk \
    dc \
    build-essential \
    snmp \
    libnet-snmp-perl \
    gettext \
    fping \
    iputils-ping \
    qstat \
    dnsutils \
    smbclient

# Construcción Nagios Core
COPY nagios-4.4.9 /nagios-4.4.9
WORKDIR /nagios-4.4.9
RUN ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
    make all && \
    make install-groups-users && \
    usermod -aG nagios www-data && \
    make install && \
    make install-init && \
    make install-daemoninit && \
    make install-commandmode && \
    make install-config && \
    make install-webconf && \
    a2enmod rewrite cgi

# Construcción Nagios Plugins
COPY nagios-plugins-2.4.2 /nagios-plugins-2.4.2
WORKDIR /nagios-plugins-2.4.2
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && \
    make install

# Construcción y instalación NRPE Plugins
COPY nrpe-4.1.0 /nrpe-4.1.0
WORKDIR /nrpe-4.1.0
RUN ./configure && \
    make all && \
    make install-plugin

WORKDIR /root

# Copia las credenciales de autenticación básica
COPY .env /usr/local/nagios/etc/

# Agregar archivo simple para health check
RUN echo "OK" > /var/www/html/ping

# Permitir acceso sin autenticación a /ping para el health check
RUN echo '<Location "/ping">\n  Require all granted\n</Location>' >> /etc/apache2/apache2.conf

# Eliminar la redirección automática para evitar problemas con health checks
# (No agregamos RedirectMatch ^/$ /nagios)

# Agregar script de inicio
ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]