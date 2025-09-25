#!/bin/bash
# Auto-setup GitLab project after deployment
# This runs after GitLab is fully ready

set -e

GITLAB_URL="http://192.168.56.111:8080"
GITLAB_NS="gitlab"

echo "🔧 Auto-configuring GitLab project..."
echo "===================================="

# Wait for GitLab to be fully ready
echo "⏳ Ensuring GitLab is fully initialized..."
sleep 60

# Get GitLab root password
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n $GITLAB_NS -ojsonpath='{.data.password}' | base64 --decode)

echo "✅ GitLab is ready for project creation!"
echo ""
echo "📋 MANUAL SETUP REQUIRED (2 minutes):"
echo "======================================"
echo "1. 🌐 Open: $GITLAB_URL"
echo "2. 🔑 Login: root / $GITLAB_PASSWORD"
echo "3. 📂 Create project: 'wil-app' (PUBLIC visibility)"
echo "4. 📄 Upload files from /home/vagrant/gitlab/app-manifests/"
echo "5. ✅ Verify project URL: $GITLAB_URL/root/wil-app"
echo ""
echo "Then run: kubectl apply -f /home/vagrant/confs/will-app.yaml"
echo "======================================"