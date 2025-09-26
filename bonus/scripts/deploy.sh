# Create K3d cluster, install GitLab and ArgoCD, configure integration
# WORKFLOW: K3d -> GitLab -> ArgoCD -> Config -> Passwords

#!/bin/bash
set -e

# === CONFIGURATION VARIABLES ===
CLUSTER_NAME="gitlab-cluster"
GITLAB_NS="gitlab"
ARGOCD_NS="argocd"
DEV_NS="dev"
GITLAB_DOMAIN="192.168.56.111"

echo "🚀 Starting GitLab + ArgoCD deployment..."
echo "========================================="

echo "[1/8] Creating K3d cluster with port mappings..."
# Create stable cluster with proper resource limits
k3d cluster create $CLUSTER_NAME \
  -p "8080:30888@loadbalancer" \
  -p "31080:31080@loadbalancer" \
  --agents 1 \
  --k3s-arg "--disable=traefik@server:*" \
  --k3s-arg "--disable=servicelb@server:*" \
  --wait --timeout 600s || echo "Cluster might already exist"

# Ensure cluster is stable before proceeding
echo "⏳ Waiting for cluster to stabilize..."
sleep 30

echo "[2/8] Configuring kubeconfig..."
mkdir -p /home/vagrant/.kube
k3d kubeconfig get $CLUSTER_NAME > /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
export KUBECONFIG=/home/vagrant/.kube/config

# Verify cluster connectivity before proceeding
echo "⏳ Verifying cluster connectivity..."
for i in {1..10}; do
  if kubectl get nodes >/dev/null 2>&1; then
    echo "✅ Cluster connectivity verified"
    break
  fi
  echo "⏳ Waiting for cluster... ($i/10)"
  sleep 10
done

echo "[3/8] Creating Kubernetes namespaces..."
kubectl create namespace $GITLAB_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $ARGOCD_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $DEV_NS --dry-run=client -o yaml | kubectl apply -f -

echo "[4/8] GitLab will be installed with Kubernetes manifests..."

echo "[5/8] Installing GitLab CE with simple Kubernetes manifests..."
echo "⚠️  This approach is more reliable than Helm chart..."
kubectl apply -f /home/vagrant/confs/gitlab-simple.yaml

echo "[6/8] Installing ArgoCD..."
kubectl apply -n $ARGOCD_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[7/8] Applying custom configurations..."
kubectl apply -f /home/vagrant/confs/argocd-server.yaml

echo "[8/8] Waiting for services to be ready..."
echo "⏳ Waiting for ArgoCD server (up to 10 minutes)..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NS

echo "⏳ Waiting for GitLab deployment..."
kubectl wait --for=condition=available --timeout=900s deployment/gitlab -n $GITLAB_NS

echo "⏳ Allowing GitLab to fully initialize (3 minutes)..."
sleep 180

# Verify GitLab is responding
echo "🔍 Testing GitLab connectivity..."
for i in {1..20}; do
  if curl -s -o /dev/null -w "%{http_code}" http://192.168.56.111:8080 | grep -q "200\|302"; then
    echo "✅ GitLab is responding"
    break
  fi
  echo "⏳ Waiting for GitLab response... ($i/20)"
  sleep 15
done

# Verify GitLab is responding
echo "🔍 Testing GitLab connectivity..."
for i in {1..10}; do
  if curl -s -o /dev/null -w "%{http_code}" http://192.168.56.111:8080 | grep -q "200\|302"; then
    echo "✅ GitLab is responding"
    break
  fi
  echo "⏳ Waiting for GitLab response... ($i/10)"
  sleep 15
done

echo "✅ Basic configuration applied"

echo "🔑 Extracting passwords..."
# GitLab password
kubectl exec -n $GITLAB_NS deployment/gitlab -- grep 'Password:' /etc/gitlab/initial_root_password | cut -d' ' -f2 > /tmp/gitlab-root-password.txt || echo "Password will be available after GitLab fully starts"
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
echo "     Password: $(cat /tmp/gitlab-root-password.txt 2>/dev/null || echo 'Check /tmp/gitlab-root-password.txt in a few minutes')"
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

# Run auto-setup
echo ""
echo "🚀 Running auto-setup..."
bash /home/vagrant/scripts/auto-setup.sh