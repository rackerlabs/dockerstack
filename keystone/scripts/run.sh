#!/bin/bash
export PGPASSFILE=/opt/dockerstack/pgpass
echo "$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT:*:docker:docker" > $PGPASSFILE
chmod 0600 $PGPASSFILE
psql -h $DB_PORT_5432_TCP_ADDR -p $DB_PORT_5432_TCP_PORT -U docker --no-password \
    -f /opt/dockerstack/scripts/keystone.sql
sed -i "s/^connection.*/connection = postgresql:\/\/keystone:keystone@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT\/keystone/" /etc/keystone/keystone.conf
sed -i "s/^\#admin_token.*/admin_token=ADMIN_TOKEN/" /etc/keystone/keystone.conf
sed -i "s/^\#provider.*/provider=keystone.token.providers.uuid.Provider/" /etc/keystone/keystone.conf
su -s /bin/sh -c "keystone-manage db_sync" keystone
start-stop-daemon --start --chuid keystone --chdir /var/lib/keystone --name keystone --exec /usr/bin/keystone-all
