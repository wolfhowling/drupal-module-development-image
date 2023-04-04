FROM php:8.1-apache

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        libicu-dev \
        sqlite3 \
        libsqlite3-dev \
        libzip-dev \
        unzip \
        libxml2-dev \
        libssl-dev \
        libcurl4-gnutls-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libonig-dev && \
    rm -rf /var/lib/apt/lists/*

# Enable required PHP extensions
RUN docker-php-ext-install \
    intl \
    pdo \
    pdo_sqlite \
    zip \
    opcache \
    xml \
    gd \
    openssl \
    json \
    curl \
    mbstring

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Drush
RUN composer global require drush/drush

# Copy Drupal project to /var/www/html/drupal
WORKDIR /var/www/html
RUN composer create-project drupal/recommended-project drupal

# Set Apache document root to /var/www/html/drupal/web
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}/drupal/web!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}/drupal/web!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Drupal using Drush
WORKDIR /var/www/html/drupal
RUN drush si --db-url=sqlite://sites/default/files/.ht.sqlite --account-pass=AdminOpen --yes

# Add and eneable devel module
RUN composer require 'drupal/devel'
RUN drush en devel

# Expose Apache default port
EXPOSE 80
