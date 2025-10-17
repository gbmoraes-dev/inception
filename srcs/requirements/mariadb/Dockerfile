FROM alpine:3.21

RUN apk add --no-cache mariadb mariadb-client \
  && mkdir -p /run/mysqld /var/log/mysql /var/lib/mysql \
  && mariadb-install-db --user=root --datadir=/var/lib/mysql \
  && chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql \
  && rm -rf /var/cache/apk/* \
  && rm -rf /usr/share/doc/* \
  && rm -rf /usr/share/man/*

COPY conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf
COPY --chmod=755 tools/init.sh /usr/local/bin/init.sh

USER mysql

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/init.sh" ]
