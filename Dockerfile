# ================================================================================================================
#
# Pydio with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php-plus
# @see https://github.com/pydio/pydio-core
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php-plus:5.6.14

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Pydio env variables
ENV PYDIO_VERSION="6.0.8"

# Get Pydio and install it
RUN mkdir -p --mode=777 /var/backup/pydio \
    && mkdir -p --mode=777 /usr/src/pydio \
    && curl -o pydio.tgz -SL https://github.com/pydio/pydio-core/archive/pydio-core-$PYDIO_VERSION.tar.gz \
    && tar -xzf pydio.tgz --strip-components=3 -C /usr/src/pydio pydio-core-pydio-core-$PYDIO_VERSION/core/src \
        --exclude=.gitignore \
        --exclude=.htaccess \
    && rm pydio.tgz \
    && chown -Rfv nginx:nginx /usr/src/pydio \
    && sed -i -e "s%output_buffering = 4096%output_buffering = Off%g" $PHP_INI_DIR/php.ini \
    && sed -i -e "s%max_execution_time = 60%max_execution_time = 14400%g" $PHP_INI_DIR/php.ini \
    && sed -i -e "s%post_max_size = 8M%post_max_size = 1G%g" $PHP_INI_DIR/php.ini \
    && sed -i -e "s%upload_max_filesize = 2M%upload_max_filesize = 1G%g" $PHP_INI_DIR/php.ini \
    && sed -i -e "s%//define(\"AJXP_LOCALE\", \"en_EN.UTF-8\");%define(\"AJXP_LOCALE\", \"en_EN.UTF-8\");%g" /usr/src/pydio/conf/bootstrap_conf.php

# NGINX tuning for pydio
COPY ./nginx/conf/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Volume for pydio backup
VOLUME /var/backup/pydio

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
