#!/bin/bash

set -e

sudo docker-compode pull
sudo docker stack deploy -c <(sudo docker-compose config) router
