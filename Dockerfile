FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
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
    smbclient && \
    apt clean

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

# Instalación NRPE Plugin
COPY nrpe-4.1.0 /nrpe-4.1.0
WORKDIR /nrpe-4.1.0
RUN ./configure && \
    make all && \
    make install-plugin

WORKDIR /root

# Copiar archivo de entorno
COPY .env /usr/local/nagios/etc/

# Copiar script de arranque
ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]
