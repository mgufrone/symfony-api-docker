#FROM php:8.3-apache as base
#
#RUN apt update && apt install -y --no-install-recommends curl libxml2-dev git unzip zip
#RUN docker-php-source extract && \
#    docker-php-ext-install ctype iconv xml intl && \
#    docker-php-ext-enable ctype iconv xml intl && \
#    docker-php-source delete

## composer setup and install the dependency
FROM --platform=$BUILDPLATFORM mgufrone/symfony-base as composer

# install composer, copy it from the composer install instruction
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
WORKDIR /code

RUN --mount=src=composer.json,dst=composer.json \
    --mount=src=composer.lock,dst=composer.lock \
    --mount=type=cache,dst=/root/.cache/composer \
    composer install --no-scripts --no-interaction

RUN --mount=src=composer.json,dst=composer.json \
    --mount=src=composer.lock,dst=composer.lock \
    --mount=type=cache,dst=/root/.cache/composer \
    composer dump-autoload
# final image

FROM

WORKDIR /var/www/html/api
COPY infra/apache.conf /etc/apache2/sites-available/000-default.conf
COPY --chown=www-data . .
COPY --from=composer /code/vendor vendor
RUN mkdir -p var/logs var/cache && chown -R www-data:www-data var
