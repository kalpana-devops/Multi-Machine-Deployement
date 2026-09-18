# ============================================================
# Stage 1: install PHP dependencies with Composer
# ============================================================
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock* ./
# --ignore-platform-reqs: the composer image's CLI PHP version may differ
# from the php:8.2-apache runtime below; we only need vendor/ out of this stage.
RUN composer install \
--no-dev \
--no-interaction \
--optimize-autoloader \
--ignore-platform-reqs
# ============================================================
# Stage 2: runtime image — no Composer, no build tools
# ============================================================
FROM php:8.2-apache
WORKDIR /var/www/html
# Application code
COPY index.php ./
# Only the resolved dependencies come across from Stage 1
COPY --from=vendor /app/vendor ./vendor
EXPOSE 80
