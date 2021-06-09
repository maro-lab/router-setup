#!/bin/bash

set -e

./patch.sh

sudo docker-compose pull
sudo docker stack deploy -c docker-compose.yaml router
