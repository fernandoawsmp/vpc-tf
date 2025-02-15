#!/bin/bash

# Atualizar pacotes e instalar Git e Docker
sudo yum update -y
sudo yum install -y git docker

# Adicionar usuários ao grupo Docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker ssm-user
id ec2-user ssm-user
sudo newgrp docker

# Ativar e iniciar o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Instalar Docker Compose 2 para ARM64
DOCKER_COMPOSE_VERSION="v2.23.3"
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-aarch64" -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Adicionar Swap
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

# Instalar Node.js e npm para ARM64
curl -fsSL https://rpm.nodesource.com/setup_21.x | sudo bash -
sudo yum install -y nodejs