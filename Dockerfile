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
    add \
    vim \
    icu-dev \
    freetype-dev \
    nodejs \
    npm \
    redis \
    nginx \
    mysql-client \
    libicu-dev \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    libwebp-dev \
    libjpeg62-turbo-dev 

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Installing bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

# Installing PHP  dependencies

RUN docker-php-ext-install \
    bz2 \ 
    bcmath \
    calendar \
    exif \
    intl \
    iconv \
    mysqli \
    opcache \
    pdo_mysql \
    pdo \
    zip 

# configuring gd 

RUN docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Installing composer

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# installing  pm2 and  laravel echo 

RUN npm install  -g pm2  && npm install -g laravel-echo-server

# configuring Cron 

RUN echo '*  *  *  *  * /usr/local/bin/php  /var/www/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root && mkdir -p /etc/supervisor.d

#  Add supervisor configuation file

ADD master.ini /etc/supervisor.d/
RUN chmod 600 /var/spool/cron/crontabs/root

#  Add nginx configuation file

ADD default.conf /etc/nginx/conf.d/

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]

