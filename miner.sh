#!/bin/bash

# Variables
TREX_URL="https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz"
TREX_DIR="/opt/t-rex"
TREX_EXEC="$TREX_DIR/t-rex"
SERVICE_NAME="miner.service"
USER=$(whoami)

# Prompt for Ethereum Classic wallet address and worker name
read -p "Enter your Ethereum Classic wallet address: " WALLET_ADDRESS
read -p "Enter your worker name: " WORKER_NAME

# Step 1: Remove azsec-monitor package
echo "Removing azsec-monitor package..."
sudo apt remove -y azsec-monitor

# Step 2: Fix broken packages
echo "Fixing broken packages..."
sudo apt --fix-broken install -y

# Step 3: Install CUDA Toolkit
echo "Installing CUDA Toolkit..."
sudo apt install -y nvidia-cuda-toolkit

# Update and install necessary packages
echo "Updating and installing necessary packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget screen tmux

# Download and extract T-Rex Miner
echo "Downloading and extracting T-Rex Miner..."
sudo mkdir -p $TREX_DIR
sudo wget -O $TREX_DIR/t-rex-linux.tar.gz $TREX_URL
sudo tar -xvf $TREX_DIR/t-rex-linux.tar.gz -C $TREX_DIR
sudo rm $TREX_DIR/t-rex-linux.tar.gz

# Create systemd service file
echo "Creating systemd service file..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME" <<EOL
[Unit]
Description=T-Rex Miner Service
After=network.target

[Service]
ExecStart=$TREX_EXEC -a etchash -o stratum+tcp://etc.2miners.com:1010 -u $WALLET_ADDRESS.$WORKER_NAME -p x
WorkingDirectory=$TREX_DIR
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the mining service
echo "Setting up and starting the mining service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# Output status of the service
sudo systemctl status $SERVICE_NAME
