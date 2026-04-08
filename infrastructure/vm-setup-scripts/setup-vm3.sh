#!/bin/bash
# Bash script to provision VM 3 (Ubuntu 20.04 - Background Worker)

echo "🐾 PawsCare VM 3 Setup - Ubuntu 20.04"
echo "Installing Background Worker and RabbitMQ..."

# Update package list
echo -e "\n[1/5] Updating package list..."
sudo apt-get update

# Configure static IP
echo -e "\n[2/5] Configuring static IP 10.0.1.30..."
# In production, edit /etc/netplan/01-netcfg.yaml
cat << EOF
# /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses: [10.0.1.30/24]
      gateway4: 10.0.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

# Install Python 3.8 and pip
echo -e "\n[3/5] Installing Python 3.8..."
sudo apt-get install -y python3.8 python3-pip python3.8-venv

# Install RabbitMQ
echo -e "\n[4/5] Installing RabbitMQ 3.8..."
sudo apt-get install -y rabbitmq-server

# Start RabbitMQ
echo -e "\n[5/5] Starting RabbitMQ service..."
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Enable RabbitMQ management plugin
echo -e "\nEnabling RabbitMQ management plugin..."
sudo rabbitmq-plugins enable rabbitmq_management

# Create RabbitMQ queues
echo -e "\nConfiguring RabbitMQ queues..."
# Queues will be created automatically by the application

# Configure firewall
echo -e "\nConfiguring UFW firewall..."
sudo ufw allow 5672/tcp
sudo ufw allow 15672/tcp
sudo ufw allow 22/tcp
sudo ufw --force enable

# Install Python dependencies
echo -e "\nInstalling Python dependencies..."
# pip3 install celery pika requests python-dotenv Pillow reportlab

# Set up cron jobs
echo -e "\nSetting up cron jobs..."
cat << 'CRONEOF' | sudo tee /etc/cron.d/pawscare-worker
# PawsCare Background Worker Cron Jobs
59 23 * * * root python3 /opt/pawscare/tasks/reports.py daily
0 6 * * 1 root python3 /opt/pawscare/tasks/reports.py weekly
0 * * * * root python3 /opt/pawscare/tasks/reminders.py batch
CRONEOF

echo -e "\n✓ VM 3 setup complete!"
echo "Next steps:"
echo "  1. Clone PawsCare background worker code to /opt/pawscare"
echo "  2. Create Python virtual environment"
echo "  3. Install Python requirements: pip3 install -r requirements.txt"
echo "  4. Start worker: python3 /opt/pawscare/worker.py"
echo ""
echo "RabbitMQ Management UI: http://10.0.1.30:15672"
echo "Default credentials: guest/guest"

# Verify installations
echo -e "\nInstalled versions:"
echo "Python: $(python3 --version)"
echo "pip: $(pip3 --version)"
sudo rabbitmqctl status | grep RabbitMQ
