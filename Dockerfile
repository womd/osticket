# Use the official PHP 8.0 Apache image as the base
FROM php:8.1-apache

# Install necessary dependencies for osTicket, Git, and PHP extensions
RUN apt-get update && \
    apt-get install -y git libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev libxml2-dev libzip-dev unzip \
                       libc-client-dev libkrb5-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install gd intl mysqli pdo pdo_mysql zip imap && \
    pecl install apcu && docker-php-ext-enable apcu && \
    docker-php-ext-install opcache && \
    a2enmod rewrite

# Create a custom php.ini file to suppress deprecation warnings
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /usr/local/etc/php/conf.d/custom.ini


# Clone osTicket repository and deploy the code
WORKDIR /var/www/html
RUN git clone https://github.com/osTicket/osTicket.git /osticket-src && \
    cd /osticket-src && \
    php manage.php deploy --setup /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

RUN cp include/ost-sampleconfig.php include/ost-config.php
RUN chmod 0666 include/ost-config.php

# Clean up
RUN rm -rf /osticket-src/setup

# Expose port 80 for HTTP traffic
EXPOSE 80
