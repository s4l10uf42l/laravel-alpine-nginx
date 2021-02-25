FROM php:7.4-fpm-alpine

WORKDIR /var/www/html

# Essentials
RUN echo "UTC" > /etc/timezone

RUN apk add --update --no-cache \
    zip \
    unzip \
    curl  \
    sqlite \
    mariadb-client \
    jpegoptim \
    pngquant \
    optipng \
    supervisor \
    vim \
    icu-dev \
    freetype-dev \
    nodejs \
    npm \
    redis \
    nginx \
    mysql-client


RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing PHP  dependencies

RUN apk add --no-cache php \
    php-common \
    php-pdo \
    php-opcache \
    php-zip \
    php-phar \
    php-iconv \
    php-cli \
    php-curl \
    php-openssl \
    php-mbstring \
    php-tokenizer \
    php-fileinfo \
    php-json \
    php-xml \
    php-xmlwriter \
    php-simplexml \
    php-dom \
    php-tokenizer \
    php7-pecl-redis \
    php-bz2 \
    php-exif \
    php-intl \
    php-bcmath \
    php-opcache \
    php-calendar \
    php-zip


RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install and configure gd

RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j$(nproc) gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev


# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php


RUN npm install  -g pm2  && npm install -g laravel-echo-server


RUN echo '*  *  *  *  * /usr/local/bin/php  /var/www/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root && mkdir -p /etc/supervisor.d


# copy your code

#COPY . /var/www/html

# Install dependencies  

#RUN composer install --no-dev &&  npm install 

# change permissions for a folders

#RUN chmod -R 777 /var/www/storage
#RUN chmod -R 775 /var/www/bootstrap

# Cron job

RUN echo '*  *  *  *  * /usr/local/bin/php  /var/www/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root && mkdir -p /etc/supervisor.d

#  Add supervisor configuation file
ADD master.ini /etc/supervisor.d/

#  Add nginx configuation file

ADD default.conf /etc/nginx/conf.d/

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]

