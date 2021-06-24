#!/bin/bash

set -e

echo "Enter in ZeroTier's network ID"
read NETWORK_ID
echo "NETWORK_ID=$NETWORK_ID" >> .env

sudo apt update

# Install zerotier
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $NETWORK_ID

echo "Enter the Zerotier IP of the current node"
read NODE_IP
echo "NODE_IP=$NODE_IP" >> .env

echo "Enter the Zerotier IP of the backend"
read BACKEND_IP
echo "BACKEND_IP=$BACKEND_IP" >> .env

# Setup hostname
sudo hostnamectl set-hostname router-${NODE_IP}
sudo bash -c 'echo "127.0.0.1 $(hostname)" >> /etc/hosts'

# Install docker
curl -fsSL https://get.docker.com | bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Join docker swarm
echo "Enter docker swarm join token "
read SWARM_JOIN_TOKEN
sudo docker swarm join --token $SWARM_JOIN_TOKEN --advertise-addr $NODE_IP:2377 $BACKEND_IP:2377

NODE_ID=$(sudo docker info --format "{{.Swarm.NodeID}}")

echo "Run 'docker node update --label-add type=router $NODE_ID' on your manager node"
read

# Make port 53 available
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo mv resolved.conf.d/* /etc/systemd/resolved.conf.d
sudo ln -s -f /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl reload-or-restart systemd-resolved

echo "Done!"
