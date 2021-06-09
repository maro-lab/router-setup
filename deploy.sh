#!/bin/bash

set -e

./patch.sh

sudo docker-compode pull
sudo docker stack deploy -c <(sudo docker-compose config) router
