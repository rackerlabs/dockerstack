CREATE USER keystone;

ALTER USER keystone WITH PASSWORD 'password';

CREATE DATABASE keystone;

GRANT ALL PRIVILEGES ON DATABASE keystone TO keystone;
