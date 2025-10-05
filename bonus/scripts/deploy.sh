#!/bin/bash
set -e

# === CONFIGURATION ===
CLUSTER_NAME="gitlab-cluster"
GITLAB_NS="gitlab"
ARGOCD_NS="argocd"
DEV_NS="dev"
GITLAB_REPO="http://gitlab.gitlab.svc.cluster.local:80/root/wil-app.git"
APP_NAME="wil-app"

# Valid nodePort in Kubernetes range
ARGOCD_NODEPORT=31080
GITLAB_NODEPORT=30888
APP_NODEPORT=30080

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "[1/7] Creating K3D cluster..."
# Map GitLab, ArgoCD and app ports
k3d cluster create $CLUSTER_NAME \
  -p "8080:$GITLAB_NODEPORT@loadbalancer" \
  -p "$ARGOCD_NODEPORT:31080@loadbalancer" \
  -p "8888:$APP_NODEPORT@loadbalancer" || true

echo "[*] Exporting kubeconfig..."
mkdir -p $HOME/.kube
k3d kubeconfig get $CLUSTER_NAME > $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

echo "[2/7] Creating Kubernetes namespaces..."
kubectl create namespace $GITLAB_NS || true
kubectl create namespace $ARGOCD_NS || true
kubectl create namespace $DEV_NS || true

echo "[3/7] Installing GitLab..."
kubectl apply -f "$PROJECT_DIR/confs/gitlab-simple.yaml"

echo "[4/7] Waiting for GitLab to be ready (this may take 5-10 minutes)..."
kubectl wait --for=condition=available --timeout=900s deployment/gitlab -n $GITLAB_NS

echo "[5/7] Installing ArgoCD..."
kubectl apply -n $ARGOCD_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[6/7] Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NS

echo "[6.1/7] Configuring ArgoCD service..."
kubectl delete svc argocd-server -n $ARGOCD_NS || true
kubectl apply -f "$PROJECT_DIR/confs/argocd-server.yaml"

echo "[7/7] Getting passwords..."
# GitLab initial password (will be available after first boot)
echo "⏳ Waiting for GitLab initial setup..."
sleep 60

# Try to get GitLab root password
for i in {1..10}; do
  if kubectl exec -n gitlab deployment/gitlab -- cat /etc/gitlab/initial_root_password 2>/dev/null | grep "Password:" | cut -d' ' -f2 > /tmp/gitlab-root-password.txt; then
    echo "✅ GitLab password extracted"
    break
  fi
  echo "⏳ Waiting for GitLab password... ($i/10)"
  sleep 30
done

# ArgoCD password
kubectl -n $ARGOCD_NS get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /tmp/argocd-admin-password.txt

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "====================================="
echo ""
echo "🔗 ACCESS URLS:"
echo "   GitLab Web UI: http://localhost:8080"
echo "   ArgoCD Web UI: http://localhost:31080"
echo ""
echo "🔑 LOGIN CREDENTIALS:"
echo "   GitLab:"
echo "     Username: root"
if [ -f /tmp/gitlab-root-password.txt ]; then
    echo "     Password: $(cat /tmp/gitlab-root-password.txt)"
else
    echo "     Password: Will be available after GitLab boots (check with: kubectl exec -n gitlab deployment/gitlab -- cat /etc/gitlab/initial_root_password)"
fi
echo ""
echo "   ArgoCD:"
echo "     Username: admin"
echo "     Password: $(cat /tmp/argocd-admin-password.txt)"
echo ""
echo "📋 NEXT STEPS:"
echo "   1. Access GitLab at http://localhost:8080"
echo "   2. Login with root and the password above"
echo "   3. Create a public project named 'wil-app'"
echo "   4. Upload files from $PROJECT_DIR/gitlab/app-manifests/"
echo "   5. Apply ArgoCD app: kubectl apply -f $PROJECT_DIR/confs/will-app.yaml"
echo "   6. Test the deployment!"
echo "====================================="