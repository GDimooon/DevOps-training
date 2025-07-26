FROM php:8.1-cli

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    libicu-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libgd-dev \
    && docker-php-ext-install \
    bcmath \
    curl \
    zip \
    gd \
    intl \
    dom \
    xml

# Установка Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Установка рабочей директории
WORKDIR /var/www

# Копируем только composer.json для кэширования зависимостей
COPY ./app/composer.json .

# Установка зависимостей (если composer.lock нет — он будет создан)
RUN composer install --no-dev --prefer-dist --no-interaction

# Копируем остальные файлы
COPY ./app .

# Открыть порт (если нужно)
EXPOSE 8000

# Команда по умолчанию
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
