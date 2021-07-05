#!/bin/bash

set -e

if [ ! -f '.env' ]; then
  echo "Enter ZeroTier's subnet IP range"
  read SUBNET_RANGE
  echo "SUBNET_RANGE=$SUBNET_RANGE" >> .env

  echo "Enter the root domain of the server"
  read DOMAIN
  echo "DOMAIN=$DOMAIN" >> .env

  echo "Enter the backend IP"
  read BACKEND_IP
  echo "BACKEND_IP=$BACKEND_IP" >> .env

  echo "Enter Cloudflare's API token"
  read CF_API_TOKEN
  echo "CF_API_TOKEN=$CF_API_TOKEN" >> .env

  echo "Enter LE email"
  read EMAIL
  echo "EMAIL=$EMAIL" >> .env

  echo "Disabling built in DNS resolver..."
  sudo sed -i \
    -e "s/^#Cache=yes/Cache=no/g" \
    -e "s/^#DNSStubListener=yes/DNSStubListener=no/g" \
    /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved
else
  echo ""
  echo ".env present"
  echo ""
fi

# Deploy
echo ""
echo "Deploying..."
echo ""
./deploy.sh
