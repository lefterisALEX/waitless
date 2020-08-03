FROM php:7.0-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		unzip \
                vim \
		libcurl4-openssl-dev \
		libjpeg-dev \
		libpng-dev \
		libmcrypt-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mcrypt mbstring mysqli opcache curl
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite

VOLUME /var/www/html

ENV TASTYIGNITER_VERSION 2.1.1
ENV WAITLESS_VERSION 0.32

RUN set -ex; \
       	curl -o tastyigniter.zip -fSL "https://github.com/lefterisALEX/waitless/archive/${WAITLESS_VERSION}.zip"; \
        unzip tastyigniter.zip -d /usr/src/; \
        rm tastyigniter.zip; \
        mv /usr/src/waitless-${WAITLESS_VERSION}/TastyIgniter-${TASTYIGNITER_VERSION} /usr/src/tastyigniter; \
	chown -R www-data:www-data /usr/src/tastyigniter


COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
