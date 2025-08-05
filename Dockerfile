FROM ubuntu:22.04

RUN apt-get update

# Apache web server
RUN apt-get install -y apache2

# PHP from sury
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php8.1

# Required PHP extensions for core
RUN apt-get install -y php8.1-mbstring
RUN apt-get install -y php8.1-xml
RUN apt-get install -y php8.1-intl

# MySQL setup
RUN apt-get update --allow-releaseinfo-change
RUN apt-get install -y php8.1-mysql
RUN apt-get install -y mysql-server
# Make sure that we can authenticate with a password
# Need to start the service for long enough to run the alter
RUN service mysql start; \
    echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'TheRootPassword';" | mysql

# Performance improvement
RUN apt-get install -y php8.1-apcu

# Editing
RUN apt-get install -y nano

# Rewrite engine
RUN a2enmod rewrite

# Varnish
RUN apt-get install -y varnish

# Run forever
CMD ["tail", "-f", "/dev/null"]
