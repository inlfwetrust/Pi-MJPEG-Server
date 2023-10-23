#!/bin/bash

# Update the Raspberry Pi OS and packages
echo "Updating Raspberry Pi OS and packages..."
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install git -y
sudo apt install python3-pip -y
sudo apt install python3-picamera2 --no-install-recommends -y

# Enable I2C
echo "Enabling I2C..."
sudo raspi-config nonint do_i2c 0

# Clone the Pi-MJPEG-Server repository
echo "Cloning Pi-MJPEG-Server repository..."
git clone https://github.com/kingkingyyk/Pi-MJPEG-Server.git

# Change directory to the repository
cd Pi-MJPEG-Server

# (Optional) Update mjpeg_server.py if needed
# You can add code here to automatically modify mjpeg_server.py if necessary

# Move Python script to a safe location
echo "Moving Python script to /usr/local/bin..."
sudo cp mjpeg_server.py /usr/local/bin

# Install required Python packages using --break-system-packages flag
echo "Installing required Python packages with --break-system-packages..."
sudo python3 -m pip install --break-system-packages -r requirements.txt

# Create an auto-start service
echo "Setting up auto-start service..."
sudo cp mjpeg_server.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start mjpeg_server
sudo systemctl enable mjpeg_server

# Verify the server is running
echo "Verifying the server status..."
sudo systemctl status mjpeg_server

echo "Setup complete. Open your browser and visit http://<Pi IP>:<8764/Port>/"
