#!/bin/bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $ROOTDIR/postgres
docker build -t keystone-postgres .

cd $ROOTDIR
docker build -t keystone .
