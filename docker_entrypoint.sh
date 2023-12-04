#!/bin/bash

LN_PROXY_PORT=3001
RUST_LOG=debug

  POSTGRES_DATADIR="/var/lib/postgresql/15"
  POSTGRES_CONFIG="/etc/postgresql/15"

  #Start and Configure PostgreSQL
  echo 'Starting PostgreSQL database server for the first time...'
  mkdir -p $POSTGRES_DATADIR $POSTGRES_CONFIG
  mv /var/lib/main $POSTGRES_DATADIR
  chown -R postgres:postgres $POSTGRES_DATADIR
  chown -R postgres:postgres $POSTGRES_CONFIG
  chmod -R 700 $POSTGRES_DATADIR
  chmod -R 700 $POSTGRES_CONFIG
  su - postgres -c "pg_createcluster 15 lib"
  su - postgres -c "pg_ctlcluster 15 lib start"

  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=docker
  POSTGRES_DB=vss

  # Start db server
  service postgresql start
  echo 'Creating user...'
  su - postgres -c "createuser $POSTGRES_USER"
  echo 'Creating db...'
  su - postgres -c "createdb $POSTGRES_DB"
  echo 'Setting password...'
  su - postgres -c 'psql -c "ALTER USER '$POSTGRES_USER' WITH ENCRYPTED PASSWORD '"'"$POSTGRES_PASSWORD"'"';"'
  echo 'Granting db permissions...'
  su - postgres -c 'psql -c "grant all privileges on database '$POSTGRES_DB' to '$POSTGRES_USER';"'
  echo 'Creating .pgpass file...'
  echo "localhost:5432:'$POSTGRES_USER':'$POSTGRES_PASSWORD'" > $POSTGRES_DATADIR/../.pgpass
  chmod -R 0600 $POSTGRES_DATADIR/../.pgpass
  chown postgres:postgres $POSTGRES_DATADIR/../.pgpass

/app/vss-rs &
/app/ln-websocket-proxy &
nginx -g 'daemon off;'
