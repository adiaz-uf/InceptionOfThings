#!/bin/bash
set -e

echo "[1/5] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[2/5] Installing dependencies (curl, git, apt-transport-https)..."
sudo apt install -y curl git apt-transport-https ca-certificates gnupg lsb-release

echo "[3/5] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "[4/5] Installing K3D..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "[5/5] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✅ Installation completed. Please restart your session to use Docker without sudo."
