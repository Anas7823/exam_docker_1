# Utiliser Debian Buster comme base
FROM debian:buster

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    lsb-release \
    nginx \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    mysql-server \
    phpmyadmin \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Installer WordPress
RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mv wordpress /var/www/html/ \
    && chown -R www-data:www-data /var/www/html/wordpress

# Configuration de MySQL
COPY ./my.cnf /etc/mysql/my.cnf
COPY ./create_db.sql /docker-entrypoint-initdb.d/

# Configuration de phpMyAdmin
RUN echo "PMA_HOST=localhost" > /etc/phpmyadmin/config.inc.php \
    && echo "PMA_USER=wordpress_user" >> /etc/phpmyadmin/config.inc.php \
    && echo "PMA_PASSWORD=wordpress_password" >> /etc/phpmyadmin/config.inc.php

# Copier le fichier de configuration Nginx
COPY ./nginx.conf /etc/nginx/sites-available/default

# Configurer supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exposer les ports
EXPOSE 80 443

# Démarrer supervisord
CMD ["/usr/bin/supervisord"]
