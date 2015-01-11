FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#Nginx
RUN apt-get install -y nginx

#MySql
RUN apt-get install -y mysql-server

#PHP
RUN apt-get install -y php5-dev
RUN apt-get install -y php5-gd php5-json php5-mysql php5-curl
RUN apt-get install -y php5-intl php5-mcrypt php5-imagick
RUN apt-get install -y php5-fpm
RUN sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php5/fpm/php.ini
RUN sed -i "s|upload_max_filesize = 2M|upload_max_filesize = 16G|" /etc/php5/fpm/php.ini
RUN sed -i "s|post_max_size = 8M|post_max_size = 16G|" /etc/php5/fpm/php.ini
RUN sed -i "s|output_buffering = 4096|output_buffering = Off|" /etc/php5/fpm/php.ini
RUN sed -i "s|memory_limit = 128M|memory_limit = 512M|" /etc/php5/fpm/php.ini
RUN sed -i "s|;pm.max_requests = 500|pm.max_requests = 500|" /etc/php5/fpm/pool.d/www.conf

#OpenOffice
RUN apt-get install -y --no-install-recommends libreoffice-writer

#OwnCloud
RUN curl https://download.owncloud.org/community/owncloud-7.0.4.tar.bz2 | tar xj 
RUN mv owncloud /var/www && \
    chown -R www-data:www-data /var/www

#ssl
RUN mkdir -p /etc/nginx/ssl && \
    cd /etc/nginx/ssl && \
    export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo) && \
    openssl genrsa -des3 -out server.key -passout env:PASSPHRASE 2048 && \
    openssl req -new -batch -key server.key -out server.csr -subj "/C=/ST=/O=org/localityName=/commonName=org/organizationalUnitName=org/emailAddress=/" -passin env:PASSPHRASE && \
    openssl rsa -in server.key -out server.key -passin env:PASSPHRASE && \
    openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt

#Nginx Config
ADD default /etc/nginx/sites-enabled/ 

#Owncloud Config
RUN mkdir -p /var/www/config
ADD autoconfig.php /var/www/config/

#Add runit services
ADD sv /etc/service 
