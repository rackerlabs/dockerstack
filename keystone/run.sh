#!/bin/bash

CONTAINER_ID=$(docker run -d -t keystone-postgres)

DB_HOST=$(docker inspect $CONTAINER_ID | grep IPAddress | cut -d '"' -f 4)

docker run -e DB_HOST=$DB_HOST -t keystone
