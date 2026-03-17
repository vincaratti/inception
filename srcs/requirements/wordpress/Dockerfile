FROM debian:bookworm

RUN apt-get update
RUN apt-get install -y php php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-xml php-zip mariadb-client curl

RUN rm -rf /var/lib/apt/lists/* # keeping the as image small as pos.

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp #exec to bin

RUN mkdir -p /var/www/html #-p makes it safer

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

RUN mkdir -p /run/php

WORKDIR /var/www/html

EXPOSE 9000
#wp only exposed to internal network
ENTRYPOINT ["setup_wp.sh"]
#safe entrypoint going through script
