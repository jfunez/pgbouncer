FROM ubuntu:trusty
ENV DEBIAN_FRONTEND=noninteractive

ENV POSTGRES_PORT 5432
ENV PGBOUNCER_AUTH_TYPE trust
ENV PGBOUNCER_MAX_CLIENT_CONN 10000
ENV PGBOUNCER_DEFAULT_POOL_SIZE 400
ENV PGBOUNCER_SERVER_IDLE_TIMEOUT 240

RUN groupadd -r pgbouncer && useradd -r -g pgbouncer pgbouncer
RUN (echo "deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && \
     echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list)
RUN apt-get update && apt-get -y install wget
RUN wget --quiet --no-check-certificate -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get -y install pgbouncer

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown -R pgbouncer:pgbouncer /entrypoint.sh && \
    chown -R pgbouncer:pgbouncer /etc/pgbouncer && \
    mkdir -p /var/log/pgbouncer/ && \
    mkdir -p /var/run/pgbouncer/ && \
    touch /var/log/pgbouncer/pgbouncer.log && \
    chown -R pgbouncer:pgbouncer /var/log/pgbouncer && \
    chown -R pgbouncer:pgbouncer /var/run/pgbouncer

EXPOSE 6432
VOLUME /etc/pgbouncer
USER pgbouncer
CMD /entrypoint.sh
