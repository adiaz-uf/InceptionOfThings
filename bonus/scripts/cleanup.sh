#!/bin/bash
# Cleanup script for complete environment removal

set -e

echo "🧹 Starting cleanup process..."

# Delete K3D cluster
echo "[1/4] Removing K3D cluster..."
k3d cluster delete gitlab-cluster 2>/dev/null || echo "  No cluster to delete"

# Remove temporary files
echo "[2/4] Removing temporary files..."
rm -f /tmp/gitlab-root-password.txt
rm -f /tmp/argocd-admin-password.txt

# Optional: Clean kubeconfig (commented out for safety)
# echo "[3/4] Cleaning kubeconfig..."
# rm -f ~/.kube/config

echo "[3/4] Checking Docker containers..."
docker ps -a | grep -E "(gitlab|argocd|k3d)" || echo "  No related containers found"

echo "[4/4] Cleanup completed!"
echo ""
echo "ℹ️  Note: Your kubeconfig was NOT deleted for safety."
echo "   If you want to remove it manually: rm -f ~/.kube/config"
