# Keystone
OpenStack docker container for Keystone

To run keystone from the docker registry

    CONTAINER_ID=$(docker run -d -t dockerstack/keystone-postgres)

    DB_HOST=$(docker inspect $CONTAINER_ID | grep IPAddress | cut -d '"' -f 4)

    docker run -e DB_HOST=$DB_HOST -t dockerstack/keystone

To build the images manually execute the command:

    ./build.sh

To run from the built images:

    ./run.sh
