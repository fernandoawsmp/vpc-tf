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

# Cria diretórios para volumes persistentes
sudo mkdir -p /home/ec2-user/n8n

# Move-se para o diretório de trabalho
cd /home/ec2-user/n8n

# Define permissões corretas
sudo chown -R $USER:$USER /home/ec2-user/n8n

# Captura o endpoint do RDS vindo do Terraform (substitua pela variável real do Terraform)
DB_HOST=$(terraform output -raw rds_endpoint)

# Cria um arquivo init-data.sh para inicializar o banco de dados
cat <<EOF > init-data.sh
#!/bin/bash
set -e;


if [ -n "\${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "\${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	psql -v ON_ERROR_STOP=1 --username "\$POSTGRES_USER" --dbname "\$POSTGRES_DB" <<-EOSQL
		CREATE USER \${POSTGRES_NON_ROOT_USER} WITH PASSWORD '\${POSTGRES_NON_ROOT_PASSWORD}';
		GRANT ALL PRIVILEGES ON DATABASE \${POSTGRES_DB} TO \POSTGRES_NON_ROOT_USER};
		GRANT CREATE ON SCHEMA public TO \${POSTGRES_NON_ROOT_USER};
	EOSQL
else
	echo "SETUP INFO: No Environment variables given!"
fi
EOF

# Define permissões corretas
sudo chmod +x init-data.sh

# Cria um arquivo .env com variáveis sensíveis (modifique conforme necessário)
cat <<EOF > .env
# n8n
N8N_ENCRYPTION_KEY=175da018a5f60d14b09088e53d47a547
SSL_EMAIL=alisrios@alisriosti.com.br
SUBDOMAIN=n8n2
DOMAIN_NAME=alisriosti.com.br
GENERIC_TIMEZONE=America/Sao_Paulo
# Configurações do RDS PostgreSQL
DB_POSTGRESDB_HOST=n8n.c9qkwqag6uxj.us-east-1.rds.amazonaws.com
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=postgres
EOF

# Cria o arquivo docker-compose.yml
cat <<EOF > docker-compose.yml
services:
  traefik:
    container_name: traefik-proxy
    image: "traefik"
    restart: always
    command:
      - "--api=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=\${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - n8n-network
      
  n8n:
    container_name: n8n
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    labels:
      - traefik.enable=true
      - traefik.http.routers.n8n.rule=Host("\${SUBDOMAIN}.\${DOMAIN_NAME}")
      - traefik.http.routers.n8n.tls=true
      - traefik.http.routers.n8n.entrypoints=web,websecure
      - traefik.http.routers.n8n.tls.certresolver=mytlschallenge
      - traefik.http.middlewares.n8n.headers.SSLRedirect=true
      - traefik.http.middlewares.n8n.headers.STSSeconds=315360000
      - traefik.http.middlewares.n8n.headers.browserXSSFilter=true
      - traefik.http.middlewares.n8n.headers.contentTypeNosniff=true
      - traefik.http.middlewares.n8n.headers.forceSTSHeader=true
      - traefik.http.middlewares.n8n.headers.SSLHost=\${DOMAIN_NAME}
      - traefik.http.middlewares.n8n.headers.STSIncludeSubdomains=true
      - traefik.http.middlewares.n8n.headers.STSPreload=true
      - traefik.http.routers.n8n.middlewares=n8n@docker      
    environment:
      - N8N_HOST=\${SUBDOMAIN}.\${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://\${SUBDOMAIN}.\${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=\${GENERIC_TIMEZONE}      
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=\${DB_POSTGRESDB_HOST}
      - DB_POSTGRESDB_PORT=\${DB_POSTGRESDB_PORT}
      - DB_POSTGRESDB_DATABASE=\${DB_POSTGRESDB_DATABASE}
      - DB_POSTGRESDB_USER=\${DB_POSTGRESDB_USER}
      - DB_POSTGRESDB_PASSWORD=\${DB_POSTGRESDB_PASSWORD}
      - DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY}
      - DB_POSTGRESDB_CONNECTION_TIMEOUT=60000
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n-network 

volumes:
  traefik_data:
  n8n_data:

networks:
  n8n-network:
    driver: bridge    
EOF

# Inicia os containers
sudo docker compose up -d