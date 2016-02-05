# PostgreSQL and PostGIS with data container 
# ~

FROM debian:jessie 
MAINTAINER Guillaume Sueur <guillaume.sueur@neogeo-online.net>

ENV DEBIAN_FRONTEND noninteractive
ENV PG_VERSION 9.5
ENV USER docker
ENV PASS SiHRDZ3Tt13uVVyH0ZST

RUN apt-get update && apt-get install -y locales -qq
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8
# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen
# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main 9.5' >> /etc/apt/sources.list.d/pgdg.list
RUN apt-get -y install wget ca-certificates
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install postgresql-${PG_VERSION} postgresql-contrib-${PG_VERSION} postgresql-${PG_VERSION}-postgis-2.2 && rm -rf /var/lib/apt/lists/*
#ADD ./start.sh /start.sh
USER postgres
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/${PG_VERSION}/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/${PG_VERSION}/main/postgresql.conf

RUN /etc/init.d/postgresql start &&  psql --command "ALTER USER postgres WITH PASSWORD '${PASS}';"

EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql/${PG_VERSION}/main", "/var/log/postgresql", "/var/lib/postgresql/${PG_VERSION}/main"]


# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.5/bin/pg_ctl", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]

