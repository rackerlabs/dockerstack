# keystone
#
# VERSION               1.0

FROM ubuntu:latest
MAINTAINER Werner R. Mendizabal "werner.mendizabal@gmail.com"

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y git-core
RUN apt-get install -y python-dev libxml2-dev libxslt1-dev libsasl2-dev libsqlite3-dev libssl-dev libldap2-dev

RUN git clone https://github.com/openstack/keystone.git

RUN apt-get install -y python-pip

RUN pip install -r /keystone/requirements.txt
RUN pip install -r /keystone/test-requirements.txt

WORKDIR /keystone

RUN python setup.py develop

EXPOSE 5000 35357

CMD keystone-all --config-file /keystone/etc/keystone.conf.sample
