# Create K3d cluster, install GitLab and ArgoCD, configure integration
# WORKFLOW: K3d -> GitLab -> ArgoCD -> Config -> Passwords

#!/bin/bash
set -e

# === CONFIGURATION VARIABLES ===
CLUSTER_NAME="gitlab-cluster"
GITLAB_NS="gitlab"
ARGOCD_NS="argocd"
DEV_NS="dev"
GITLAB_DOMAIN="192.168.56.111.nip.io"

echo "🚀 Starting GitLab + ArgoCD deployment..."
echo "========================================="

echo "[1/8] Creating K3d cluster with port mappings..."
# Create cluster with specific ports for GitLab and ArgoCD
k3d cluster create $CLUSTER_NAME \
  -p "8080:30080@server:0" \
  -p "8443:443@loadbalancer" \
  -p "31080:31080@loadbalancer" \
  --agents 2 \
  --k3s-arg "--disable=traefik@server:*" \
  --wait --timeout 300s || echo "Cluster might already exist"

echo "[2/8] Configuring kubeconfig..."
mkdir -p /home/vagrant/.kube
k3d kubeconfig get $CLUSTER_NAME > /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
export KUBECONFIG=/home/vagrant/.kube/config

echo "[3/8] Creating Kubernetes namespaces..."
kubectl create namespace $GITLAB_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $ARGOCD_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $DEV_NS --dry-run=client -o yaml | kubectl apply -f -

echo "[4/8] Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo "[5/8] Installing GitLab CE via Helm..."
echo "⚠️  This step takes 5-10 minutes - GitLab is downloading and starting..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace $GITLAB_NS \
  --values /home/vagrant/gitlab/values.yaml \
  --timeout=1200s

echo "[6/8] Installing ArgoCD..."
kubectl apply -n $ARGOCD_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[7/8] Applying custom configurations..."
kubectl apply -f /home/vagrant/confs/argocd-server.yaml
kubectl apply -f /home/vagrant/confs/gitlab-webservice.yaml

echo "[8/8] Waiting for services to be ready..."
echo "⏳ Waiting for ArgoCD server (up to 10 minutes)..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NS

echo "⏳ Waiting for GitLab webservice (up to 15 minutes)..."
kubectl wait --for=condition=available --timeout=900s deployment/gitlab-webservice-default -n $GITLAB_NS

echo "🔑 Extracting passwords..."
# GitLab password
kubectl get secret gitlab-gitlab-initial-root-password -n $GITLAB_NS -ojsonpath='{.data.password}' | base64 --decode > /tmp/gitlab-root-password.txt
echo "GitLab root password saved to /tmp/gitlab-root-password.txt"

# ArgoCD password
kubectl -n $ARGOCD_NS get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /tmp/argocd-admin-password.txt
echo "ArgoCD admin password saved to /tmp/argocd-admin-password.txt"

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "====================================="
echo ""
echo "🔗 ACCESS URLS:"
echo "   GitLab Web UI: http://192.168.56.111:8080"
echo "   ArgoCD Web UI: http://192.168.56.111:31080"
echo ""
echo "🔑 LOGIN CREDENTIALS:"
echo "   GitLab:"
echo "     Username: root"
echo "     Password: $(cat /tmp/gitlab-root-password.txt)"
echo ""
echo "   ArgoCD:"
echo "     Username: admin"
echo "     Password: $(cat /tmp/argocd-admin-password.txt)"
echo ""
echo "📋 NEXT STEPS:"
echo "   1. Run: bash /home/vagrant/scripts/configure-gitlab.sh"
echo "   2. Follow the GitLab project setup instructions"
echo "   3. Upload the application manifests to GitLab"
echo "   4. Configure ArgoCD to sync from GitLab"
echo "   5. Test the CI/CD pipeline"
echo "====================================="

# Run verification
echo ""
echo "🔍 Running system verification..."
bash /home/vagrant/scripts/verify.sh