#!/bin/bash

set -e

echo "Enter ZeroTier's subnet IP range"
read SUBNET_RANGE
echo "SUBNET_RANGE=$SUBNET_RANGE" >> .env

echo "Enter the root domain of the server"
read DOMAIN
echo "DOMAIN=$DOMAIN" >> .env

echo "Enter Cloudflare's API token"
read CF_API_TOKEN
echo "CF_API_TOKEN=$CF_API_TOKEN" >> .env

echo "Enter LE email"
read EMAIL
echo "EMAIL=$EMAIL" >> .env

# Deploy
./deploy.sh
