FROM php:8.2-cli

ENV DEBIAN_FRONTEND=noninteractive

ARG APP_USER=laraveluser
ARG APP_GROUP=laravelgroup
ARG WORKDIR=/var/www

RUN set -xe \
    && groupadd -g 1200 ${APP_GROUP} \
    && useradd -r -g ${APP_GROUP} -u 1201 ${APP_USER} \
    && mkdir -p ${WORKDIR} \
    && chown -R ${APP_USER}:${APP_GROUP} ${WORKDIR}

RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    sudo \
    && docker-php-ext-install pdo_sqlite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR $WORKDIR

COPY . .

RUN chown -R ${APP_USER}:${APP_GROUP} $WORKDIR \
    && chmod -R 775 storage bootstrap/cache \
    && chmod -R 777 database

USER ${APP_USER}

RUN composer install

CMD php artisan serve --host=0.0.0.0 --port=8000
