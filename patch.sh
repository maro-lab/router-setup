#!/bin/bash

set -e

eval $(cat .env)

# sed config files
sed -i \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  -e 's|{{EMAIL}}|'$EMAIL'|g' \
  traefik.toml
find configs -type f \( -iname "*.yaml" ! -iname "*.template.yaml" \) -exec sed -i \
  -e 's|{{SUBNET_RANGE}}|'$SUBNET_RANGE'|g' \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  -e 's|{{DNS_IP}}|'$DNS_IP'|g' \
  -e 's|{{BACKEND_IP}}|'$BACKEND_IP'|g' \
  {} \;

# Write secret
mkdir -p secrets
echo "$CF_API_TOKEN" > secrets/cf_dns_api_token
