#!/bin/bash
# GitLab Project Setup Helper Script
# This script helps configure GitLab after initial deployment

set -e

GITLAB_URL="http://192.168.56.111:8080"
PROJECT_NAME="wil-app"
GITLAB_NS="gitlab"

echo "🔧 GitLab Configuration Helper"
echo "=============================="

# Get GitLab root password
if [ -f /tmp/gitlab-root-password.txt ]; then
    GITLAB_PASSWORD=$(cat /tmp/gitlab-root-password.txt)
else
    echo "Extracting GitLab root password..."
    kubectl get secret gitlab-gitlab-initial-root-password -n $GITLAB_NS -ojsonpath='{.data.password}' | base64 --decode > /tmp/gitlab-root-password.txt
    GITLAB_PASSWORD=$(cat /tmp/gitlab-root-password.txt)
fi

echo ""
echo "📋 MANUAL SETUP INSTRUCTIONS:"
echo "=============================="
echo ""
echo "1. 🌐 Access GitLab Web UI:"
echo "   URL: $GITLAB_URL"
echo "   Username: root"
echo "   Password: $GITLAB_PASSWORD"
echo ""
echo "2. 📂 Create a new project:"
echo "   - Click 'New project'"
echo "   - Choose 'Create blank project'"
echo "   - Project name: $PROJECT_NAME"
echo "   - Visibility Level: Public"
echo "   - Initialize repository with README: ✓"
echo "   - Click 'Create project'"
echo ""
echo "3. 📁 Upload application files:"
echo "   - Go to your project"
echo "   - Click '+' → 'Upload file'"
echo "   - Upload the files from /home/vagrant/gitlab/app-manifests/"
echo "   - Or use git clone and push:"
echo ""
echo "     git clone $GITLAB_URL/root/$PROJECT_NAME.git"
echo "     cd $PROJECT_NAME"
echo "     cp /home/vagrant/gitlab/app-manifests/* ."
echo "     git add ."
echo "     git config user.name 'Administrator'"
echo "     git config user.email 'admin@example.com'"
echo "     git commit -m 'Add application manifests'"
echo "     git push origin main"
echo ""
echo "4. 🔄 Configure ArgoCD to use GitLab:"
echo "   - The ArgoCD application is already configured"
echo "   - It will sync from: $GITLAB_URL/root/$PROJECT_NAME.git"
echo "   - ArgoCD UI: http://192.168.56.111:31080"
echo ""
echo "5. 🧪 Test the integration:"
echo "   - Make changes to deployment.yaml in GitLab"
echo "   - Switch between v1 and v2 using GitLab CI/CD"
echo "   - Watch ArgoCD sync the changes automatically"
echo "   - Test app: curl http://192.168.56.111:30888/"
echo ""
echo "=============================="
echo "🔑 CREDENTIALS SUMMARY:"
echo "=============================="
echo "GitLab (root): $GITLAB_PASSWORD"
if [ -f /tmp/argocd-admin-password.txt ]; then
    echo "ArgoCD (admin): $(cat /tmp/argocd-admin-password.txt)"
fi
echo "=============================="