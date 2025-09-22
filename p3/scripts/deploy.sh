#!/bin/bash
set -e

# === CONFIGURATION ===
CLUSTER_NAME="mycluster"
ARGOCD_NS="argocd"
DEV_NS="dev"
GITHUB_REPO="https://github.com/adiaz-uf/iot-argocd-alaparic-adiaz-uf.git"
APP_NAME="wil-app"

# Valid nodePort in Kubernetes range
ARGOCD_NODEPORT=31080

echo "[1/6] Creating K3D cluster..."
# Map your app port 8888 and ArgoCD nodePort 31080
k3d cluster create $CLUSTER_NAME -p "8888:8888@loadbalancer" -p "$ARGOCD_NODEPORT:31080@loadbalancer" || true

echo "[*] Exporting kubeconfig..."
mkdir -p /home/vagrant/.kube
k3d kubeconfig get $CLUSTER_NAME > /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
export KUBECONFIG=/home/vagrant/.kube/config

echo "[2/6] Creating Kubernetes namespaces..."
kubectl create namespace $ARGOCD_NS || true
kubectl create namespace $DEV_NS || true

echo "[3/6] Installing Argo CD..."
kubectl apply -n $ARGOCD_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[4/6] Waiting for Argo CD server to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NS

echo "[4.1/6] Replacing default Argo CD server Service with LoadBalancer with fixed nodePort $ARGOCD_NODEPORT..."
kubectl delete svc argocd-server -n $ARGOCD_NS || true
kubectl apply -f /home/vagrant/confs/argocd-server.yaml

echo "[5/6] Creating Argo CD Application from GitHub repo..."
kubectl apply -f /home/vagrant/confs/wil-app.yaml


echo "[6/6] ✅ Deployment completed!"
echo "========================================="
echo "🧠 Argo CD Web UI should be accessible at:"
echo "👉 http://192.168.56.110:$ARGOCD_NODEPORT"
echo
echo "🔐 To get the initial Argo CD admin password run:"
echo "kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NS -o jsonpath=\"{.data.password}\" | base64 -d && echo"
echo
echo "🚀 Deployed app will be available at:"
echo "http://192.168.56.110:8888"
echo "========================================="
