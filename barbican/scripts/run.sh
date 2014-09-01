#!/bin/bash

# Add Barbican test users to Keystone
/opt/dockerstack/scripts/keystone_data.sh

# Create 'barbican' DB user
export PGPASSFILE=/opt/dockerstack/pgpass
echo "$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT:*:docker:docker" > $PGPASSFILE
chmod 600 $PGPASSFILE
psql -h $DB_PORT_5432_TCP_ADDR -p $DB_PORT_5432_TCP_PORT -U docker --no-password \
    -f /opt/dockerstack/scripts/barbican.sql

# Configure Barbican to use PostgreSQL container
sed -i "s/^sql_connection.*/sql_connection = postgresql:\/\/barbican:barbican@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT\/barbican/" /etc/barbican/barbican-api.conf

# Configure Paste to use Keystone
sed -i "s/^\/v1.*/\/v1: barbican-api-keystone/" /etc/barbican/barbican-api-paste.ini
sed -i "s/^auth_host.*/auth_host = $KEYSTONE_PORT_35357_TCP_ADDR/" /etc/barbican/barbican-api-paste.ini
sed -i "s/^auth_port.*/auth_port = $KEYSTONE_PORT_35357_TCP_PORT/" /etc/barbican/barbican-api-paste.ini

# Run Barbican
uwsgi --master --emperor /etc/barbican/vassals
