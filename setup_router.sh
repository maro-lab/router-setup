#!/bin/bash

set -e

sudo apt update

# Install Tailscale

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update
sudo apt install tailscale

sudo tailscale up

NODE_IP=$(sudo tailscale ip | head -n 1)
echo "NODE_IP=$NODE_IP" >> .env

echo "Enter the Tailscale IP of the backend"
read BACKEND_IP
echo "BACKEND_IP=$BACKEND_IP" >> .env

# Setup hostname
sudo hostnamectl set-hostname router-${NODE_IP}
sudo bash -c 'echo "127.0.0.1 $(hostname)" >> /etc/hosts'

# Install docker
curl -fsSL https://get.docker.com | bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Configuring metrics exporter"
# Configure metrics exporter
echo '{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker

# Join docker swarm
echo "Enter docker swarm join token "
read SWARM_JOIN_TOKEN
sudo docker swarm join --token $SWARM_JOIN_TOKEN --advertise-addr $NODE_IP:2377 $BACKEND_IP:2377

NODE_ID=$(sudo docker info --format "{{.Swarm.NodeID}}")

echo "Run 'docker node update --label-add type=router $NODE_ID' on your manager node"
read

echo "Done!"
