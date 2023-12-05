#!/bin/bash

LN_PROXY_PORT=3001
RUST_LOG=debug

POSTGRES_DATADIR="/var/lib/postgresql/15"
POSTGRES_CONFIG="/etc/postgresql/15"
CLUSTER_NAME="main"

# Start and Configure PostgreSQL
echo 'Starting PostgreSQL database server...'

# Move main directory if it doesn't exist in the target
if [ ! -d "$POSTGRES_DATADIR/$CLUSTER_NAME" ]; then
  echo 'Moving PostgreSQL data directory...'
  mkdir -p "$POSTGRES_DATADIR" "$POSTGRES_CONFIG"
  mv /var/lib/main "$POSTGRES_DATADIR"
else
  echo "Target directory '$POSTGRES_DATADIR/$CLUSTER_NAME' already exists. Skipping move operation."
fi

# Set ownership and permissions
chown -R postgres:postgres "$POSTGRES_DATADIR" "$POSTGRES_CONFIG"
chmod -R 700 "$POSTGRES_DATADIR" "$POSTGRES_CONFIG"

# Start PostgreSQL cluster
su - postgres -c "pg_ctlcluster 15 $CLUSTER_NAME start"

POSTGRES_USER=postgres
POSTGRES_PASSWORD=docker
POSTGRES_DB=vss

# Create user if not exists
su - postgres -c "createuser $POSTGRES_USER" 2>/dev/null || true

# Create database if not exists
su - postgres -c "createdb --encoding=UTF8 $POSTGRES_DB" 2>/dev/null || true

echo 'Setting password...'
su - postgres -c 'psql -c "ALTER USER '$POSTGRES_USER' WITH ENCRYPTED PASSWORD '"'"$POSTGRES_PASSWORD"'"';"'

echo 'Granting db permissions...'
su - postgres -c 'psql -c "grant all privileges on database '$POSTGRES_DB' to '$POSTGRES_USER';"'

echo 'Creating .pgpass file...'
echo "localhost:5432:$POSTGRES_DB:$POSTGRES_USER:$POSTGRES_PASSWORD" >"$POSTGRES_DATADIR/../.pgpass"
chmod 0600 "$POSTGRES_DATADIR/../.pgpass"
chown postgres:postgres "$POSTGRES_DATADIR/../.pgpass"

/app/vss-rs &
/app/ln-websocket-proxy &
nginx -g 'daemon off;'
