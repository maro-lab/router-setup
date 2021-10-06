#!/bin/bash

set -e

sudo apt update
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades

echo "Enter the chosen ssh port"
read SSH_PORT
echo "SSH_PORT=$SSH_PORT" >> .env

echo "Configuring ssh"
sudo sed -i -e 's|#Port 22|Port '$SSH_PORT'|g' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Configuring the firewall"
sudo apt install ufw -y
sudo ufw reset
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow $SSH_PORT/tcp
sudo ufw allow 996,7946,4789,2377/tcp
sudo ufw allow 7946,4789,2377/udp

echo "Configuring tailscale"
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale

sudo tailscale up --advertise-tags=tag:router

sudo ufw allow 41641/udp
sudo ufw allow in on tailscale0

NODE_IP=$(sudo tailscale ip | head -n 1)
echo "NODE_IP=$NODE_IP" >> .env

# Configure tailscale access control
echo "Update your Tailscale ACLs at https://login.tailscale.com/admin/acls"
echo "Tailscale router IP: $NODE_IP"
read
echo ""

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

# Configure DNS redirects
echo "Update your DNS redirects for *.internal domains"
echo "Tailscale router IP: $NODE_IP"
read
echo ""

echo "Enabling firewall"
sudo ufw enable

echo "Done!"
