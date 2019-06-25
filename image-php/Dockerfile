# Referencias:
# https://github.com/docker-library/wordpress/tree/master/php7.3/fpm
FROM wordpress:php7.3-fpm

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
  libtidy-dev \
  zlib1g-dev \
  libmemcached-dev \
  locales \
  git
  
RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8

ENV LANG pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8
  
RUN pecl install apcu \
  pecl install msgpack \
  pecl install igbinary

RUN docker-php-ext-install pdo_mysql \
  && docker-php-ext-install tidy \
  && docker-php-ext-enable apcu \
  && docker-php-ext-enable msgpack \
  && docker-php-ext-enable igbinary

# Instalação da extensão memcached
RUN curl -kL -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/v3.1.3.tar.gz" \
  && mkdir -p /usr/src/php/ext/memcached \
  && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
  && docker-php-ext-configure memcached --enable-memcached-igbinary --enable-memcached-json --enable-memcached-msgpack

# Instalação da extensão redis
RUN mkdir -p /usr/src/php/ext/redis \
  && curl -kL https://github.com/phpredis/phpredis/archive/4.3.0.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
  && echo 'redis' >> /usr/src/php-available-exts

RUN docker-php-ext-install redis \
  && docker-php-ext-install memcached

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

RUN { \
    echo 'memory_limit = 2048M'; \
    echo 'post_max_size = 2000M'; \
    echo 'upload_max_filesize = 2000M'; \
    echo 'max_execution_time = 300'; \
    echo 'date.timezone = "America/Sao_Paulo"'; \
    echo 'max_input_vars = 4000'; \
    echo 'realpath_cache_ttl = 300'; \
    echo 'output_buffering = 4096'; \
} > /usr/local/etc/php/conf.d/extra-conf.ini
