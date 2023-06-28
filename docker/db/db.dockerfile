FROM mariadb:10.9.4-jammy
LABEL maintainer="David Luis david.lu1992@gmail.com"

EXPOSE 3306/tcp
EXPOSE 3306/udp

COPY ./docker/db/phpmyadmin.sql /docker-entrypoint-initdb.d/phpmyadmin.sql
