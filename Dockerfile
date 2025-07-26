FROM php:8.2-fpm

# Установка системных зависимостей
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
    openssh-client \
    && apt-get clean

# Установка PHP расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Рабочая директория
WORKDIR /var/www

# Копируем только composer.* для кэширования зависимостей
COPY app/composer.json app/composer.lock ./

# Настройка зеркала и таймаута для РФ
RUN composer config -g repos.packagist composer https://mirrors.cloud.tencent.com/composer/ && \
    composer config -g process-timeout 1800 && \
    composer install --no-interaction --prefer-dist --optimize-autoloader

# Копируем всё приложение
COPY ./app /var/www

# Установка прав
RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]
