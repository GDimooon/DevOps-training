FROM php:8.2-fpm

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev \
    npm openssh-client \
 && rm -rf /var/lib/apt/lists/*

# Установка PHP-расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Добавление composer из официального stage
FROM composer:2.7 AS composer_stage

FROM php:8.2-fpm

COPY --from=composer_stage /usr/bin/composer /usr/bin/composer

# Рабочая директория
WORKDIR /var/www

# Копируем только composer файлы сначала (для кэширования)
COPY composer.json composer.lock ./

# Установка mirrors и зависимостей
RUN composer config -g repos.packagist composer https://mirrors.cloud.tencent.com/composer/ && \
    composer config -g process-timeout 1800 && \
    composer install --no-interaction --prefer-dist --optimize-autoloader

# Копируем остальной код
COPY ./app /var/www
COPY app/.env /var/www/.env

# Права
RUN chown -R www-data:www-data /var/www

EXPOSE 9000

CMD ["php-fpm"]
