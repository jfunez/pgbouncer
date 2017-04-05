#!/bin/sh

set -e

POSTGRES_HOST=${POSTGRES_HOST:-}
POSTGRES_PORT=${POSTGRES_PORT:-}
POSTGRES_USER=${POSTGRES_USER:-}
POSTGRES_PASS=${POSTGRES_PASS:-}
PGBOUNCER_MAX_CLIENT_CONN=${PGBOUNCER_MAX_CLIENT_CONN:-}
PGBOUNCER_DEFAULT_POOL_SIZE=${PGBOUNCER_DEFAULT_POOL_SIZE:-}
PGBOUNCER_SERVER_IDLE_TIMEOUT=${PGBOUNCER_SERVER_IDLE_TIMEOUT:-}

if [ -f /etc/pgbouncer/pgbconf.ini ]
then
    echo "file: /etc/pgbouncer/pgbconf.ini already exists... continue"
else
    cat << EOF > /etc/pgbouncer/pgbconf.ini
[databases]
* = host=${POSTGRES_HOST} port=${POSTGRES_PORT}

[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
;listen_addr = *
listen_addr = 0.0.0.0
listen_port = 6432
unix_socket_dir = /var/run/pgbouncer
auth_type = trust
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = session
server_reset_query = DISCARD ALL
max_client_conn = ${PGBOUNCER_MAX_CLIENT_CONN}
default_pool_size = ${PGBOUNCER_DEFAULT_POOL_SIZE}
ignore_startup_parameters = extra_float_digits
server_idle_timeout = ${PGBOUNCER_SERVER_IDLE_TIMEOUT}
EOF
fi

if [ ! -s /etc/pgbouncer/userlist.txt ]
then
    echo '"'"${POSTGRES_USER}"'" "'"${POSTGRES_PASS}"'"'  > /etc/pgbouncer/userlist.txt
fi

chown -R pgbouncer:pgbouncer /etc/pgbouncer
chmod 640 /etc/pgbouncer/userlist.txt

pgbouncer -u pgbouncer /etc/pgbouncer/pgbconf.ini
