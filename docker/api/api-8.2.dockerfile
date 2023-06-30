FROM php:8.2.1-apache-bullseye
LABEL maintainer="David Luis david.lu1992@gmail.com"

EXPOSE 80/tcp
EXPOSE 80/udp
EXPOSE 443/tcp
EXPOSE 443/udp

# Init ARG
ARG GIT_NAME
ARG GIT_EMAIL
ARG GIT_REPO
ARG GIT_BRANCH
ARG GIT_RSA
ARG GIT_RSA_PUB
ARG DOCKER_DIR

COPY ${GIT_RSA} /root/.ssh/id_rsa
COPY ${GIT_RSA_PUB} /root/.ssh/id_rsa.pub
COPY ${GIT_RSA_PUB} /root/.ssh/authorized_keys

RUN echo "Host *" > /root/.ssh/config
RUN echo "  StrictHostKeyChecking no" >> /root/.ssh/config

RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 644 /root/.ssh/id_rsa.pub
RUN chmod 644 /root/.ssh/authorized_keys
RUN chmod 400 /root/.ssh/config

# Init ENV
ENV APP_RUN_CRON_JOBS true
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Config Apache
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

#Library for managing images
RUN apt-get update && apt-get install -y \
    ssh \
    acl \
    sudo \
    zip \
    curl \
    cron \
    openssl \
    unzip \
    git \
    wget \
    nano \
    vim \
    autoconf \
    nmap \
    iputils-ping \
    supervisor \
    build-essential \
    gnupg \
    dos2unix \
    zsh \
    bash-completion \
    pkg-config \
    mariadb-client

RUN apt-get install -y libmcrypt-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libcurl3-dev \
    libssl-dev \
    libmemcached-dev \
    libc-client-dev \
    libicu-dev \
    libkrb5-dev \
    libz-dev \
    libonig-dev

RUN mkdir -p /var/run/sshd \
    && echo "mkdir -p /var/run/sshd" >> /etc/rc.local \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/* \
    && pecl install memcached redis \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install pdo pdo_mysql gd mysqli soap xml mbstring bcmath gd zip curl \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable pdo_mysql mysqli soap xml mbstring bcmath gd zip curl memcached redis \
    && apt-get clean

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Enable a2mods
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_wstunnel
RUN a2enmod ssl

# Enable site-ssl
RUN a2ensite default-ssl

# install composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/composer.phar && \
    chmod +x /usr/local/bin/composer

# Install PHPUnit
RUN composer global require phpunit/phpunit
ENV PATH="/root/.composer/vendor/bin:${PATH}"

#Xdebug
RUN pecl install xdebug-3.2.0 \
    && docker-php-ext-enable xdebug

RUN echo "xdebug.default_enable = 1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_handler = dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    #COULD CHECK HOW TO MAKE THIS WORK SO NO NEED TO SPECIFY LOCAL IP ADDRESS IN DOCKER_COMPOSE
    #echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    echo "xdebug.remote_port = 9000" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.profiler_output_dir=\"/tmp\"" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN git clone ${GIT_REPO} /var/www/html
RUN git config --global user.name "${GIT_NAME}"
RUN git config --global user.email "${GIT_EMAIL}"
RUN git config --global --add safe.directory /var/www/html
RUN cd /var/www/html
RUN git fetch
RUN git checkout ${GIT_BRANCH}

# Crons
RUN echo "SHELL=/bin/bash" > /etc/cron.d/crons
RUN echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >> /etc/cron.d/crons
RUN echo "" >> /etc/cron.d/crons
RUN echo "* * * * *      root   sudo -u www-data php /var/www/html/artisan schedule:run >> /dev/null 2>&1" >> /etc/cron.d/crons
RUN echo "1 * * * *      root   chown -R www-data:www-data /var/www >> /dev/null 2>&1" >> /etc/cron.d/crons
RUN echo "@reboot        root   sudo -u www-data php /var/www/html/artisan schedule:run >> /dev/null 2>&1" >> /etc/cron.d/crons
RUN echo "" >> /etc/cron.d/crons
RUN chmod +x /etc/cron.d/crons

# Copy init scripts
COPY ${DOCKER_DIR}/entrypoint.sh /usr/local/bin/
RUN dos2unix /usr/local/bin/entrypoint.sh
RUN ln -s /usr/local/bin/entrypoint.sh /
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/bin/bash","/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]