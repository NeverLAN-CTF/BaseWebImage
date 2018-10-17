FROM alpine 

MAINTAINER NeverLAN CTF Team <info@neverlanctf.com>

# Update packages and install supervisord
RUN apk update && apk upgrade && \
    apk add supervisor

# Install MariaDB and client
RUN apk add mariadb && \
    apk add mariadb-client && \
    apk add mariadb-dev

# Install NGINX and PHP7
RUN \
    apk add libressl && \
    apk add curl openssl && \
    apk add nginx && \
    apk add php7 php7-openssl php7-mbstring && \
    apk add php7-apcu php7-intl php7-mcrypt php7-json php7-gd php7-curl && \
    apk add php7-fpm php7-mysqlnd php7-pgsql php7-sqlite3 php7-phar && \
    apk add php7-session php7-mysqli

# Install and setup composer
RUN \
    # install composer
    cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

RUN \
    chmod 1777 /var/tmp && \
    mysql_install_db --user=mysql

RUN \
    rm -rf /var/cache/apk/*

RUN mkdir /run/nginx && \
    rm -r /var/www/localhost && \
    mkdir /var/www/html

RUN echo "[include]" >> /etc/supervisord.conf && \
    echo "files = /etc/supervisor/conf.d/*.conf" >> /etc/supervisord.conf

COPY supervisord/mariadb.conf /etc/supervisor/conf.d/
COPY supervisord/nginx.conf /etc/supervisor/conf.d/
COPY supervisord/phpfpm.conf /etc/supervisor/conf.d/
COPY conf/nginx-php-fpm.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
