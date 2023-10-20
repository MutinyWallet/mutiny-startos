#!/bin/bash

LN_PROXY_PORT=3001
RUST_LOG=debug

  POSTGRES_DATADIR="/var/lib/postgresql/15"
  POSTGRES_CONFIG="/etc/postgresql/15"

  # Pulling this in from Dockerfile
  # IDK why but it gets mad if you don't do this
  git config --global --add safe.directory /app
  pnpm run build

  #Start and Configure PostgreSQL
  echo 'Starting PostgreSQL database server for the first time...'
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
  su - postgres -c 'echo "localhost:5432:'$POSTGRES_USER':'$POSTGRES_PASSWORD'" >> .pgpass'
  su - postgres -c "chmod -R 0600 .pgpass"
  chmod -R 0600 /var/lib/postgresql/.pgpass

/app/vss-rs &
/app/ln-websocket-proxy &
nginx -g 'daemon off;'