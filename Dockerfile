FROM php:8.2-fpm

# Установка зависимостей для PHP и Node
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
    npm \
    openssh-client

# Установка PHP расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Установка composer из composer:latest
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка mirrors для РФ и увеличение таймаута
RUN composer config -g repos.packagist composer https://mirrors.cloud.tencent.com/composer/ && \
    composer config -g process-timeout 1800

# Рабочая директория
WORKDIR /var/www

# Копируем код приложения
COPY ./app /var/www
COPY app/.env /var/www/.env
RUN chown -R www-data:www-data /var/www
# Установка зависимостей с использованием composer.lock, если он есть
RUN if [ -f composer.lock ]; then \
        composer install --no-interaction --prefer-dist --optimize-autoloader; \
    else \
        composer update --no-interaction --prefer-dist --optimize-autoloader; \
    fi

# Права на папку
RUN chown -R www-data:www-data /var/www

EXPOSE 9000

CMD ["php-fpm"]
