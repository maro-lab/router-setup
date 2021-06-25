#!/bin/bash

set -e

./patch.sh

VERSION=$(cat version | awk 'BEGIN{FS=OFS="."} {$2+=1} 1')

sudo VERSION=$VERSION docker-compose pull

echo "Updating availability of router nodes..."
sudo docker node update --availability active $(sudo docker node ls -q --filter node.label=type=router)
sleep 5

sudo VERSION=$VERSION bash -c 'VERSION=$VERSION docker stack deploy -c <(VERSION=$VERSION docker-compose config) --with-registry-auth router'

echo "Pausing availability of router nodes..."
sudo docker node update --availability pause $(sudo docker node ls -q --filter node.label=type=router)
sleep 5

echo "$VERSION" > version
