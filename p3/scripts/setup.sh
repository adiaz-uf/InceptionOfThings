#!/bin/bash
set -e

echo "[1/5] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[2/5] Installing dependencies (curl, git, apt-transport-https)..."
sudo apt install -y curl git apt-transport-https ca-certificates gnupg lsb-release

echo "[3/5] Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "Docker installed. You may need to log out and log back in for group changes to take effect."
else
    echo "Docker already installed."
fi

echo "[4/5] Installing K3D..."
if ! command -v k3d &> /dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "K3D already installed."
fi

echo "[5/5] Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl already installed."
fi

echo "✅ Installation completed!"
echo "⚠️  If Docker was just installed, you may need to:"
echo "   1. Log out and log back in, OR"
echo "   2. Run 'newgrp docker' to use Docker without sudo in this session"
