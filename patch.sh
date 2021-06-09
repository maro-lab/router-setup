#!/bin/bash

set -e

eval .env

# sed config files
sed -i \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  -e 's|{{EMAIL}}|'$EMAIL'|g' \
  traefik.toml
find configs -type f -exec sed -i \
  -e 's|{{SUBNET_RANGE}}|'$SUBNET_RANGE'|g' \
  -e 's|{{BACKEND_IP}}|captain-nginx|g' \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  {} \;

# Write secret
mkdir -p secrets
echo "$CF_API_TOKEN" > secrets/cf_dns_api_token
