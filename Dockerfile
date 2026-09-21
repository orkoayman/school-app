FROM php:8.2-apache
RUN apt-get update && apt-get install -y libicu-dev libpq-dev libzip-dev unzip git \
 && docker-php-ext-install intl mysqli pgsql pdo_pgsql \
 && a2enmod rewrite
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN sed -ri 's!/var/www/html!/var/www/ci/public!g' /etc/apache2/sites-available/*.conf \
 && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
 && sed -i 's/80/10000/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf
RUN composer create-project codeigniter4/appstarter /var/www/ci --no-dev --no-interaction
WORKDIR /var/www/ci
COPY school-app.zip /tmp/school-app.zip
RUN unzip -q /tmp/school-app.zip -d /tmp/x \
 && APPDIR=$(dirname "$(find /tmp/x -type d -name Controllers | head -1)") \
 && cp -r "$APPDIR"/. app/ \
 && chown -R www-data:www-data writable
CMD ["sh","-c","cp /etc/secrets/.env .env; php spark migrate; apache2-foreground"]
