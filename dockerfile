FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    npm

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY ./app /var/www

RUN composer install --no-interaction --prefer-dist --optimize-autoloader
#RUN npm install && npm run production
RUN chown -R www-data:www-data /var/www

EXPOSE 9000

CMD ["php-fpm"]
