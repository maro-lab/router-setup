#!/bin/bash

set -e

./patch.sh

VERSION=$(cat version | awk 'BEGIN{FS=OFS="."} {$2+=1} 1')

sudo VERSION=$VERSION docker-compose pull


sudo VERSION=$VERSION bash -c 'VERSION=$VERSION docker stack deploy -c <(VERSION=$VERSION docker-compose config) --with-registry-auth router'

echo "$VERSION" > version

