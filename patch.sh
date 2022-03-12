#!/bin/bash

set -e

eval $(cat .env)

for file in $(find configs -type f -name '*.template.yaml'); do
    yes | cp -fr -- "$file" "${file%%.template.yaml}.yaml"
done

yes | cp -fr traefik.template.toml traefik.toml

# sed config files
sed -i \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  -e 's|{{DOMAIN_ALT}}|'$DOMAIN_ALT'|g' \
  -e 's|{{EMAIL}}|'$EMAIL'|g' \
  traefik.toml
find configs -type f \( -iname "*.yaml" ! -iname "*.template.yaml" \) -exec sed -i \
  -e 's|{{SUBNET_RANGE}}|'$SUBNET_RANGE'|g' \
  -e 's|{ { SUBNET_RANGE } }|'$SUBNET_RANGE'|g' \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' \
  -e 's|{{DOMAIN_ALT}}|'$DOMAIN_ALT'|g' \
  -e 's|{{DNS_IP}}|'$DNS_IP'|g' \
  -e 's|{{BACKEND_IP}}|'$BACKEND_IP'|g' \
  {} \;

# Write secret
mkdir -p secrets
echo "$CF_API_TOKEN" > secrets/cf_dns_api_token
