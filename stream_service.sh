#!/bin/bash

# Update the system
echo "Updating system..."
sudo apt update && sudo apt -y full-upgrade

# Install necessary software
echo "Installing libcamera-apps..."
sudo apt install -y libcamera-apps

echo "Installing VLC..."
sudo apt install -y vlc

# Allow VLC to run as root
echo "Configuring VLC to run as root..."
sudo sed -i 's/geteuid/getppid/' /usr/bin/vlc

# List available cameras
echo "Listing available cameras..."
libcamera-hello --list-cameras

# Create the streaming script
echo "Creating streaming script..."
cat <<EOF > ~/stream.sh
#!/bin/bash
libcamera-vid -t 0 --inline --width 1920 --height 1080 --framerate 15 -o - | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/stream}' :demux=h264
EOF

# Make the script executable
chmod +x ~/stream.sh

# Create the service
echo "Creating service..."
cat <<EOF | sudo tee /lib/systemd/system/stream.service
[Unit]
Description=Custom Webcam Streaming Service
After=multi-user.target

[Service]
Type=simple
ExecStart=/home/pi/stream.sh
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Set permissions for the service file
sudo chmod 644 /lib/systemd/system/stream.service

# Enable the service
echo "Enabling service..."
sudo systemctl enable stream.service

# Start the service
echo "Starting service..."
sudo service stream start

# Check the service status
echo "Checking service status..."
sudo service stream status
