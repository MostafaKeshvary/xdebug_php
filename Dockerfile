FROM docker.arvancloud.ir/php:8.4.3-apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    inetutils-ping \
    net-tools \
    telnet \
    netcat-traditional \
    && docker-php-ext-install pdo pdo_mysql zip \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN touch /tmp/xdebug.log
RUN chmod 777 /tmp/xdebug.log

COPY config/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . /var/www/html

RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/apache2.conf

RUN chown -R www-data:www-data /var/www/html

