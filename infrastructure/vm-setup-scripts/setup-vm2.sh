#!/bin/bash
# Bash script to provision VM 2 (Ubuntu 20.04 - API Server)

echo "🐾 PawsCare VM 2 Setup - Ubuntu 20.04"
echo "Installing API Server and MongoDB..."

# Update package list
echo -e "\n[1/6] Updating package list..."
sudo apt-get update

# Configure static IP
echo -e "\n[2/6] Configuring static IP 10.0.1.20..."
# In production, edit /etc/netplan/01-netcfg.yaml
# For demo purposes, showing configuration
cat << EOF
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses: [10.0.1.20/24]
      gateway4: 10.0.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

# Install Node.js 14.x
echo -e "\n[3/6] Installing Node.js 14.x..."
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MongoDB 4.4
echo -e "\n[4/6] Installing MongoDB 4.4..."
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
echo -e "\n[5/6] Starting MongoDB service..."
sudo systemctl start mongod
sudo systemctl enable mongod

# Install PM2 for process management
echo -e "\n[6/6] Installing PM2..."
sudo npm install -g pm2

# Configure firewall
echo -e "\n[7/6] Configuring UFW firewall..."
sudo ufw allow 3000/tcp
sudo ufw allow 27017/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

echo -e "\n✓ VM 2 setup complete!"
echo "Next steps:"
echo "  1. Clone PawsCare API server code"
echo "  2. Run 'npm install' in api-server directory"
echo "  3. Run 'pm2 start server.js --name pawscare-api'"
echo "  4. Configure MongoDB connection in .env file"

# Verify installations
echo -e "\nInstalled versions:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "MongoDB: $(mongod --version | head -n 1)"
