#!/bin/bash
#
# dockerstack.sh
#   DockerStack is currently being used to test Barbican using a real database
#   and Keystone for auth.

function fail () {
  # fail(exit_code, message)
  exit_code=$1
  message=$2

  printf "%s" $message > /dev/stderr
    exit $exit_code
}

function cleanup () {
  # Delete virtualenv
  pyenv uninstall -f cloudcafe_$BUILD_NUMBER

  # Remove containers
  docker stop $barbican_container
  docker stop $keystone_container
  docker stop $postgresql_container

  docker rm $barbican_container
  docker rm $keystone_container
  docker rm $postgresql_container

  # Remove Docker images
  docker rmi dockerstack/barbican:$BUILD_NUMBER
  docker rmi dockerstack/keystone:$BUILD_NUMBER
  docker rmi dockerstack/postgresql:$BUILD_NUMBER
}

eval "$(pyenv init -)"

# Build Docker images
docker build -t dockerstack/postgresql:$BUILD_NUMBER $WORKSPACE/dockerstack/postgresql
docker build -t dockerstack/keystone:$BUILD_NUMBER $WORKSPACE/dockerstack/keystone
docker build -t dockerstack/barbican:$BUILD_NUMBER $WORKSPACE/dockerstack/barbican

# Run Docker containers
db_container=$(docker run -d -P --name postgresql_$BUILD_NUMBER dockerstack/postgresql:$BUILD_NUMBER)
keystone_container=$(docker run -d -P --name keystone_$BUILD_NUMBER --link postgresql_$BUILD_NUMBER:db dockerstack/keystone:$BUILD_NUMBER)
barbican_container=$(docker run -d -P --name barbican_$BUILD_NUMBER --link postgresql_$BUILD_NUMBER:db --link keystone_$BUILD_NUMBER:keystone dockerstack/barbican:$BUILD_NUMBER)

# Clone cloud cafe projects
rm -rf $WORKSPACE/opencafe
rm -rf $WORKSPACE/cloudcafe
rm -rf $WORKSPACE/cloudroast
git clone https://github.com/cloudkeep/opencafe.git $WORKSPACE/opencafe
git clone https://github.com/cloudkeep/cloudcafe.git $WORKSPACE/cloudcafe
git clone https://github.com/cloudkeep/cloudroast.git $WORKSPACE/cloudroast

# Set up cafe virtualenv
pyenv virtualenv 2.7.8 cloudcafe_$BUILD_NUMBER
pyenv shell cloudcafe_$BUILD_NUMBER
pip install opencafe/ --upgrade
pip install cloudcafe/ --upgrade
pip install cloudroast/ --upgrade
pyenv rehash
cafe-config plugins install skip_on_issue

# Configure cloud-cafe
config=~/.opencafe/configs/cloudkeep/reference.config

keystone_port=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "5000/tcp") 0).HostPort}}' keystone_$BUILD_NUMBER)
barbican_port=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "9311/tcp") 0).HostPort}}' barbican_$BUILD_NUMBER)

sed -i "s/<base_url>/http:\/\/127.0.0.1:$barbican_port/g" $config
sed -i "s/<auth_endpoint>/http:\/\/127.0.0.1:$keystone_port/g" $config
sed -i "s/<auth_endpoint>/http:\/\/127.0.0.1:$keystone_port/g" $config
sed -i "s/<auth_type>/keystone/g" $config
sed -i "s/<keystone_user>/admin_user/g" $config
sed -i "s/<keystone_password>/password/g" $config
sed -i "s/<keystone_tenant_name>/demo/g" $config
sed -i "s/<github_token>/$GITHUB_TOKEN/g" $config

sed -i "s/<rbac_admin>/admin_user/g" $config
sed -i "s/<rbac_admin_password>/password/g" $config

sed -i "s/<rbac_creator>/creator_user/g" $config
sed -i "s/<rbac_creator_password>/password/g" $config

sed -i "s/<rbac_observer>/observer_user/g" $config
sed -i "s/<rbac_observer_password>/password/g" $config

sed -i "s/<rbac_audit>/audit_user/g" $config
sed -i "s/<rbac_audit_password>/password/g" $config

# Run Tests
cafe-runner cloudkeep reference -p barbican --result xml --result-directory $WORKSPACE
status=$?

cleanup
exit $status
