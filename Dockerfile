# Utiliser Debian Buster comme base
FROM debian:buster

# Changer le miroir à un autre qui pourrait être accessible
RUN sed -i 's|http://deb.debian.org/debian|http://ftp.fr.debian.org/debian|g' /etc/apt/sources.list

# Installer les dépendances nécessaires
RUN apt-get update --fix-missing && apt-get install -y \
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
    mariadb-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Télécharger et installer phpMyAdmin manuellement
RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz \
    && tar -xzf phpMyAdmin-latest-all-languages.tar.gz \
    && mv phpMyAdmin-*-all-languages /usr/share/phpmyadmin \
    && rm phpMyAdmin-latest-all-languages.tar.gz \
    && ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Installer WordPress
RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mv wordpress /var/www/html/ \
    && chown -R www-data:www-data /var/www/html/wordpress

# Configuration de MySQL
COPY ./my.cnf /etc/mysql/my.cnf
COPY ./create_db.sql /docker-entrypoint-initdb.d/

# Copier le fichier de configuration Nginx
COPY ./nginx.conf /etc/nginx/sites-available/default

# Configurer index.html
COPY index.html /var/www/html/

# Exposer les ports
EXPOSE 80 443

# Démarrer supervisord
CMD ["/usr/bin/supervisord"]
