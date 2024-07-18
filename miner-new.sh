#!/bin/bash

# Variables
read -p "Enter the app data file url: " TREX_URL
TREX_DIR="/opt/app"
TREX_EXEC="$TREX_DIR/app"
SERVICE_NAME="app.service"
USER=$(whoami)
POOL_URL="stratum+tcp://etc.2miners.com:1010"
ALGO="etchash"

# Prompt for Ethereum Classic wallet address and worker name
read -p "Enter your Ethereum Classic wallet address: " WALLET_ADDRESS
read -p "Enter your worker name: " WORKER_NAME

# Download and extract T-Rex Miner
echo "Downloading and extracting T-Rex Miner..."
sudo mkdir -p $TREX_DIR
sudo wget -O $TREX_DIR/app.tar.gz $TREX_URL
sudo tar -xvf $TREX_DIR/app.tar.gz -C $TREX_DIR
sudo mv $TREX_DIR/t-rex $TREX_EXEC
sudo rm $TREX_DIR/app.tar.gz

# Create systemd service file
echo "Creating systemd service file..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME" <<EOL
[Unit]
Description=Application Service
After=network.target

[Service]
ExecStart=$TREX_EXEC -a $ALGO -o $POOL_URL -u $WALLET_ADDRESS.$WORKER_NAME -p x
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
