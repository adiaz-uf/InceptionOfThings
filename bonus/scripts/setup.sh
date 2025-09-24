#!/bin/bash
# Install Docker, K3d, kubectl and Helm into the VM
set -e

echo "[1/6] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "[2/6] Installing basic dependencies..."
sudo apt install -y curl git apt-transport-https ca-certificates gnupg lsb-release wget

echo "[3/6] Installing Docker (required for K3d)..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker vagrant
echo "Docker installed - user added to docker group"

echo "[4/6] Installing K3d (consistent with P3)..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
echo "K3d installed successfully"

echo "[5/6] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "kubectl installed and configured"

echo "[6/6] Installing Helm (needed for GitLab)..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "✅ All tools installed successfully!"