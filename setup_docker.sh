#!/bin/bash

set -e

echo "Enter in ZeroTier's network ID"
read NETWORK_ID

echo "Enter ZeroTier's subnet IP range"
read SUBNET_RANGE

echo "Enter the backend's ZeroTier IP"
read BACKEND_IP

echo "Enter the root domain of the server"
read DOMAIN

echo "Enter Cloudflare's API token"
read CF_API_TOKEN

echo "Enter LE email"
read EMAIL

sudo apt update

# Install zerotier
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $NETWORK_ID

echo "Enter the Zerotier IP of the current node"
read NODE_IP

# Install docker
curl -fsSL https://get.docker.com | bash

# Join docker swarm
echo "Enter docker swarm join token"
read SWARM_JOIN_TOKEN
sudo docker swarm join --token $SWARM_JOIN_TOKEN --advertise-addr $NODE_IP:2377 $BACKEND_IP:2377

# Setup hostname
sudo hostnamectl set-hostname router

# Make port 53 available
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo mv resolved.conf.d/* /etc/systemd/resolved.conf.d
sudo ln -s -f /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl reload-or-restart systemd-resolved

# sed config files
sed -i 's|{{DOMAIN}}|'$DOMAIN'|g' traefik.toml
sed -i 's|{{EMAIL}}|'$EMAIL'|g' traefik.toml
find configs -type f -exec sed -i \
  -e 's|{{SUBNET_RANGE}}|'$SUBNET_RANGE'|g' \
  -e 's|{{BACKEND_IP}}|'$BACKEND_IP'|g' \
  -e 's|{{DOMAIN}}|'$DOMAIN'|g' {} \;

# Write secret
mkdir -p secrets
echo "$CF_API_TOKEN" > secrets/cf_dns_api_token

# Deploy
./deploy.sh
