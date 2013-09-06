#!/bin/bash

echo $DB_HOST

sed -i "/\[sql\]/aconnection = postgresql://keystone:password@$DB_HOST:5432/keystone?client_encoding=utf8" /keystone/etc/keystone.conf.sample

STATUS=2

while [ $STATUS -ne 0 ]
do
    PGPASSWORD=password psql -h $DB_HOST -p 5432 -U keystone -c 'select 1'
    STATUS=$?
    sleep 1
done

keystone-manage --config-file /keystone/etc/keystone.conf.sample db_sync

keystone-all --config-file /keystone/etc/keystone.conf.sample
