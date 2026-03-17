FROM debian:bookworm

RUN apt-get update

RUN apt-get install -y nginx openssl

RUN rm -rf /var/lib/apt/lists/* #clearing for memory

COPY conf/nginx.conf /etc/nginx/sites-available/default
#moving config file to default config location
COPY tools/setup_ssl.sh /usr/local/bin/setup_ssl.sh
#moving ssl creation script to accessible directory during execution
RUN chmod +x /usr/local/bin/setup_ssl.sh

EXPOSE 443

ENTRYPOINT ["setup_ssl.sh"]
#like other modules, started at the end of the script
