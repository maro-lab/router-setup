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

# Download and untar the binary
wget -O traefik.tar.gz https://github.com/traefik/traefik/releases/download/v2.4.8/traefik_v2.4.8_linux_386.tar.gz
tar -xvf traefik.tar.gz

# Move it to the bin folder and set permissions
sudo mv ./traefik /usr/local/bin
sudo chown root:root /usr/local/bin/traefik
sudo chmod 755 /usr/local/bin/traefik
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik

# Create nd config traefik user
sudo groupadd -g 321 traefik
sudo useradd \
  -g traefik --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 321 traefik

# Create traefik config folders
sudo mkdir /etc/traefik
sudo mkdir /etc/traefik/acme
sudo chown -R root:root /etc/traefik
sudo chown -R traefik:traefik /etc/traefik/acme

# Move static config file
sudo mv traefik.toml /etc/traefik
sudo chown root:root /etc/traefik/traefik.toml
sudo chmod 644 /etc/traefik/traefik.toml
sudo sed -i "s/{{DOMAIN}}/$DOMAIN/g" /etc/traefik/traefik.toml
sudo sed -i "s/{{EMAIL}}/$EMAIL/g" /etc/traefik/traefik.toml

# Move dynamic configs
sudo mkdir /etc/traefik/configs
sudo mv configs/* /etc/traefik/configs/
sudo chown -R root:root /etc/traefik/configs/*
sudo chmod -R 644 /etc/traefik/configs/*
sudo find /etc/traefik/configs -type f -exec sed -i \
  -e "s/{{SUBNET_RANGE}}/$SUBNET_RANGE/g" \
  -e "s/{{BACKEND_IP}}/$BACKEND_IP/g" \
  -e "s/{{DOMAIN}}/$DOMAIN/g" {} \;

# Move secrets
sudo mkdir /etc/traefik/secrets
echo "$CF_API_TOKEN" > secrets/cf_dns_api_token
sudo mv secrets/* /etc/traefik/secrets/
sudo chown -R root:root /etc/traefik/secrets/*
sudo chmod -R 644 /etc/traefik/secrets/*

# Make port 53 available
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo mv resolved.conf.d/* /etc/systemd/resolved.conf.d
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl reload-or-restart systemd-resolved

# Install and enable service
sudo mv traefik.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/traefik.service
sudo chmod 644 /etc/systemd/system/traefik.service
sudo systemctl daemon-reload
sudo systemctl start traefik.service
sudo systemctl enable traefik.service

# Install zerotier
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $NETWORK_ID
