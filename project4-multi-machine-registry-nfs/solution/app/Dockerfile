# Stage 1: install PHP dependencies with Composer
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock* ./
RUN composer install \
  --no-dev \
  --no-interaction \
  --optimize-autoloader \
  --ignore-platform-reqs

# Stage 2: runtime image — no Composer, no build tools
FROM php:8.2-apache
WORKDIR /var/www/html
COPY index.php ./
COPY --from=vendor /app/vendor ./vendor
EXPOSE 80
