#!/bin/bash
sudo docker stop barbican
sudo docker stop keystone
sudo docker stop postgres

sudo docker rm barbican
sudo docker rm keystone
sudo docker rm postgrs

sudo docker run -d --name postgres dockerstack/postgresql
sleep 30
sudo docker run -d --name keystone -p 5000:5000 -p 35357:35357 --link postgres:db dockerstack/keystone
sleep 30
sudo docker run -d --name barbican -p 9311:9311 --link postgres:db --link keystone:keystone dockerstack/barbican
