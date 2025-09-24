#!/bin/bash
# Verification script for GitLab + ArgoCD integration
# Tests all components and connections

set -e

echo "🔍 IoT Bonus - System Verification"
echo "=================================="

# Check if kubectl is working
echo "[1/8] Checking kubectl connectivity..."
if kubectl get nodes > /dev/null 2>&1; then
    echo "✅ kubectl is working"
else
    echo "❌ kubectl not working"
    exit 1
fi

# Check namespaces
echo "[2/8] Checking namespaces..."
for ns in gitlab argocd dev; do
    if kubectl get namespace $ns > /dev/null 2>&1; then
        echo "✅ Namespace '$ns' exists"
    else
        echo "❌ Namespace '$ns' missing"
    fi
done

# Check GitLab pods
echo "[3/8] Checking GitLab deployment..."
GITLAB_READY=$(kubectl get pods -n gitlab -l app=webservice --no-headers 2>/dev/null | wc -l)
if [ "$GITLAB_READY" -gt 0 ]; then
    echo "✅ GitLab webservice pods found: $GITLAB_READY"
else
    echo "⏳ GitLab webservice not ready yet"
fi

# Check ArgoCD
echo "[4/8] Checking ArgoCD deployment..."
if kubectl get deployment argocd-server -n argocd > /dev/null 2>&1; then
    ARGOCD_READY=$(kubectl get deployment argocd-server -n argocd -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [ "$ARGOCD_READY" -gt 0 ]; then
        echo "✅ ArgoCD server is ready"
    else
        echo "⏳ ArgoCD server not ready yet"
    fi
else
    echo "❌ ArgoCD server not found"
fi

# Check ArgoCD Application
echo "[5/8] Checking ArgoCD Application..."
if kubectl get application wil-app -n argocd > /dev/null 2>&1; then
    echo "✅ ArgoCD Application 'wil-app' exists"
    APP_STATUS=$(kubectl get application wil-app -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
    echo "   Sync Status: $APP_STATUS"
else
    echo "⏳ ArgoCD Application not found - will be created after GitLab setup"
fi

# Check application pods in dev namespace
echo "[6/8] Checking application pods..."
APP_PODS=$(kubectl get pods -n dev -l app=wil-playground --no-headers 2>/dev/null | wc -l)
if [ "$APP_PODS" -gt 0 ]; then
    echo "✅ Application pods found in dev namespace: $APP_PODS"
else
    echo "⏳ No application pods found yet (normal if GitLab project not set up)"
fi

# Check services and accessibility
echo "[7/8] Checking service accessibility..."

# GitLab
GITLAB_SVC=$(kubectl get svc -n gitlab -l app=webservice --no-headers 2>/dev/null | wc -l)
if [ "$GITLAB_SVC" -gt 0 ]; then
    echo "✅ GitLab service available"
    echo "   Access at: http://192.168.56.111.nip.io:8080"
else
    echo "⏳ GitLab service not ready"
fi

# ArgoCD
ARGOCD_SVC=$(kubectl get svc -n argocd argocd-server --no-headers 2>/dev/null | wc -l)
if [ "$ARGOCD_SVC" -gt 0 ]; then
    echo "✅ ArgoCD service available"
    echo "   Access at: http://192.168.56.111:31080"
else
    echo "⏳ ArgoCD service not ready"
fi

# Check credentials files
echo "[8/8] Checking credential files..."
if [ -f /tmp/gitlab-root-password.txt ]; then
    echo "✅ GitLab password file exists"
else
    echo "⏳ GitLab password file not found"
fi

if [ -f /tmp/argocd-admin-password.txt ]; then
    echo "✅ ArgoCD password file exists"
else
    echo "⏳ ArgoCD password file not found"
fi

echo ""
echo "=================================="
echo "🎯 VERIFICATION SUMMARY"
echo "=================================="

# Overall status
ALL_READY=true

# Critical components check
kubectl get pods -n gitlab -l app=webservice --no-headers 2>/dev/null | grep -q "Running" || ALL_READY=false
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers 2>/dev/null | grep -q "Running" || ALL_READY=false

if [ "$ALL_READY" = true ]; then
    echo "🟢 SYSTEM STATUS: READY"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Run: bash /home/vagrant/scripts/configure-gitlab.sh"
    echo "   2. Follow the GitLab setup instructions"
    echo "   3. Test the CI/CD pipeline"
else
    echo "🟡 SYSTEM STATUS: INITIALIZING"
    echo ""
    echo "⏳ Some components are still starting up."
    echo "   Wait a few minutes and run this script again."
fi

echo "=================================="