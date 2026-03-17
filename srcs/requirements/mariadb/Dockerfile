FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld

RUN chown mysql:mysql /run/mysqld

COPY conf/mariadb_config.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_db.sh /usr/local/bin/init_db.sh

RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["init_db.sh"]

