# pgbouncer
Docker Image for pgbouncer, with 'ubuntu:trusty' as a base image.

This image accepts enviroment variables to define the `pgbouncer.ini` configuration file.

## Configurations:

### ENVs

- `POSTGRES_HOST`: host of the PostgreSQL server.
- `POSTGRES_PORT`: port of the PostgreSQL server. **Default**: 5432.
- `POSTGRES_USER`: username of the PostgreSQL server.
- `POSTGRES_PASS`: password of the PostgreSQL server.
- `PGBOUNCER_AUTH_TYPE`: `auth_type` - How to authenticate users. **Default**: `trust`. More info at: https://pgbouncer.github.io/config.html
- `PGBOUNCER_MAX_CLIENT_CONN`: `max_client_conn` - Maximum number of client connections allowed. **Default**: 10000. More info at: https://pgbouncer.github.io/config.html
- `PGBOUNCER_DEFAULT_POOL_SIZE`: `default_pool_size` - How many server connections to allow per user/database pair. **Default**: 400. More info at: https://pgbouncer.github.io/config.html
- `PGBOUNCER_SERVER_IDLE_TIMEOUT`: `server_idle_timeout` -  If a server connection has been idle more than this many seconds it will be dropped. If 0 then timeout is disabled. [seconds]. **Default**: 240.


### Using confs from files in volume:

The container enable a volume: /etc/pgbouncer
Here you can place your files to customize the pgbouncer confs.
If any of these files exists in the mapped volume will be prioritized instead env var.

### /etc/pgbouncer/pgbconf.ini

At start, the `entrypoint.sh` script will check if this file exists.
If exists, will be used. Else, will be generated a new one with the confs defined in ENV vars.

### /etc/pgbouncer/userlist.txt

At start, the `entrypoint.sh` script will check if this file exists.
If exists, will be used. Else, will be generated a new one with the confs defined in ENV vars.

## How to use:

### 1. create a postgres container with custom username and password:

```
docker run \
    --name some-postgres \
    -e POSTGRES_USER=jfunez \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -d postgres
```

With thie command, will start a new postgres container with a valid `jfunez` user.

### 2. create a new pgbouncer container and connect it to postgres:

```
docker run -i -t \
    -p 6432:6432 \
    --link some-postgres:postgres  \
    -e POSTGRES_HOST=postgres \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_USER=jfunez \
    -e POSTGRES_PASS=mysecretpassword \
    jfunez/pgbouncer
```

With this command, will create a new pgbouncer container, linked to postgres, and creating a custom configuration using the `-e` variables defined.
The output will be something like this:

```
2017-04-05 18:45:53.408 11 LOG File descriptor limit: 1048576 (H:1048576), max_client_conn: 10000, max fds possible: 10010
2017-04-05 18:45:53.408 11 LOG listening on 0.0.0.0:6432
2017-04-05 18:45:53.408 11 LOG listening on unix:/var/run/pgbouncer/.s.PGSQL.6432
2017-04-05 18:45:53.409 11 LOG process up: pgbouncer 1.7.2, libevent 2.0.21-stable (epoll), adns: evdns2, tls: OpenSSL 1.0.1f 6 Jan 2014
```

#### Testing a connection:

Now you can connect against pgbouncer container (normally at: `localhost:6432`).
Once connected the pgbouncer container logs will output:

```
2017-04-05 19:30:18.820 11 LOG C-0x22b7a40: (nodb)/(nouser)@172.17.0.1:59050 registered new auto-database: db = jfunez
2017-04-05 19:30:18.820 11 LOG C-0x22b7a40: jfunez/jfunez@172.17.0.1:59050 login attempt: db=jfunez user=jfunez tls=no
2017-04-05 19:30:18.820 11 LOG S-0x22bc6f0: jfunez/jfunez@172.17.0.2:5432 new connection to server (from 172.17.0.3:34704
```

If you quit (hiting `CTRL+C`) the pgbouncer container, it will exit **only** when all connections were closed.

