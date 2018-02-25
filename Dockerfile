# Base Image for NeverLAN CTF Challenges
# Taken from Alpine
FROM scratch
ADD rootfs.tar.xz /
CMD ["/bin/sh"]

MAINTAINER NeverLAN CTF Team <info@neverlanctf.com>

##################################################################
# Install Apache
RUN apk update && apk upgrade && \
    apk add --no-cache apache2 libxml2-dev apache2-utils && \
    sed -i 's#/var/log/apache2/#/web/logs/#g' /etc/logrotate.d/apache2 && \
    sed -i 's/Options Indexes/Options /g' /etc/apache2/httpd.conf


##################################################################
# Install Php7
RUN \
    apk add libressl && \
    apk add curl openssl && \
    apk add php7 php7-apache2 php7-openssl php7-mbstring && \
    apk add php7-apcu php7-intl php7-mcrypt php7-json php7-gd php7-curl && \
    apk add php7-fpm php7-mysqlnd php7-pgsql php7-sqlite3 php7-phar &&\
    # install composer
    cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer



##################################################################
# Install MySQL
RUN apk add mariadb && \
    apk add mariadb-client && \
    apk add mariadb-dev && \
    apk add openssl
#RUN apk add --no-cache mysql-client


RUN echo "[include]" >> /etc/supervisord.conf && \
    echo "files = /etc/supervisor/conf.d/*.conf" >> /etc/supervisord.conf

COPY mysql.conf /etc/supervisor/conf.d/

# create mysql password for root and set to /tmp/pass_root file
RUN \
    export MYSQL_PASS=$(openssl rand -hex 100) && \
    echo $MYSQL_PASS > /tmp/pass_root && \
    export MYSQL_PASS=$(openssl rand -hex 100) && \
    echo $MYSQL_PASS > /tmp/pass_web



RUN \
	rm /tmp/pass_root && \
    rm -rf /var/cache/apk/*

##################################################################
# ports
EXPOSE 3306
EXPOSE 80
#EXPOSE 443

##################################################################
# specify healthcheck script
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]
