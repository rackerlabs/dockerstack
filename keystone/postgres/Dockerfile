# keystone
#
# VERSION               1.0

FROM ubuntu:latest
MAINTAINER Werner R. Mendizabal "werner.mendizabal@gmail.com"

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y postgresql postgresql-client

ADD keystone.sql keystone.sql

RUN service postgresql start && su -c "psql -f keystone.sql" -s /bin/sh postgres

RUN sed -i "s/#listen_addresses.*/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf

RUN echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/9.1/main/pg_hba.conf

EXPOSE 5432

CMD service postgresql start && tail -f /var/log/postgresql/postgresql-9.1-main.log
