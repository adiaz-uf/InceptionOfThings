#!/bin/bash
set -e

echo "[+] Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[+] Installing dependencies..."
sudo apt-get install -y curl vim git

echo "[+] Installing K3s in server mode..."
# Install K3s with kubeconfig accesible for every user
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644" sh -

echo "[+] Exporting kubeconfig..."
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

echo "[+] K3s installed and ready. Use 'kubectl get nodes' to verify."
