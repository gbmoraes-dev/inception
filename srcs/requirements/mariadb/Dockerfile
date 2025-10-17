FROM alpine:3.21 AS builder

RUN apk add --no-cache mariadb mariadb-client

FROM alpine:3.21 AS final

RUN apk add --no-cache libstdc++ libaio pcre2

RUN addgroup -S mysql && adduser -S -G mysql mysql

COPY --from=builder /usr/bin/mariadb-admin /usr/bin/
COPY --from=builder /usr/bin/mariadbd /usr/bin/
COPY --from=builder /usr/bin/my_print_defaults /usr/bin/
COPY --from=builder /usr/bin/mariadb-install-db /usr/bin/
COPY --from=builder /usr/share/mariadb /usr/share/mariadb/
COPY --from=builder /usr/lib/mariadb /usr/lib/mariadb/

RUN mkdir -p /run/mysqld /var/log/mysql /var/lib/mysql && chown -R mysql:mysql /run/mysqld /var/log/mysql /var/lib/mysql

COPY conf/99-custom.cnf /etc/my.cnf.d/99-custom.cnf
COPY --chmod=755 tools/init.sh /usr/local/bin/init.sh

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/init.sh" ]

CMD [ "mariadbd", "--user=mysql", "--console" ]
