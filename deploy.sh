#!/bin/bash

set -e

sudo docker stack deploy -c <(docker-compose config) router
