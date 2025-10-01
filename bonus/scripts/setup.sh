#!/bin/bash
# Install Docker, K3d and kubectl into the VM
set -e

echo "[1/5] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "[2/5] Installing basic dependencies..."
sudo apt install -y curl git apt-transport-https ca-certificates gnupg lsb-release wget

echo "[3/5] Installing Docker (required for K3d)..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker vagrant
echo "Docker installed - user added to docker group"

echo "[4/5] Installing K3d (consistent with P3)..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
echo "K3d installed successfully"

echo "[5/5] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "kubectl installed and configured"

echo "✅ All tools installed successfully!"