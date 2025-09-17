#!/bin/bash
set -e

# === CONFIGURATION ===
CLUSTER_NAME="mycluster"
ARGOCD_NS="argocd"
DEV_NS="dev"
GITHUB_REPO="https://github.com/adiaz-uf/iot-argocd-alaparic-adiaz-uf.git"
APP_NAME="wil-app"

echo "[1/6] Creating K3D cluster..."
k3d cluster create $CLUSTER_NAME -p "8888:8888@loadbalancer" || true

echo "[*] Exporting kubeconfig..."
mkdir -p /home/vagrant/.kube
k3d kubeconfig get $CLUSTER_NAME > /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
export KUBECONFIG=/home/vagrant/.kube/config

echo "[2/6] Creating namespaces..."
kubectl create namespace $ARGOCD_NS || true
kubectl create namespace $DEV_NS || true

echo "[3/6] Installing ArgoCD..."
kubectl apply -n $ARGOCD_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[4/6] Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NS

echo "[5/6] Creating ArgoCD Application..."
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APP_NAME
  namespace: $ARGOCD_NS
spec:
  project: default
  source:
    repoURL: $GITHUB_REPO
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEV_NS
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "[6/6] Deployment completed!"
echo "✅ Cluster: $CLUSTER_NAME"
echo "✅ Namespaces: $ARGOCD_NS, $DEV_NS"
echo "✅ ArgoCD Application created: $APP_NAME"
echo
echo "👉 To test the app from the host machine: curl http://192.168.56.110:8888/"
