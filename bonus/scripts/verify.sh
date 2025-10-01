#!/bin/bash
# Simple verification for GitLab + ArgoCD setup

echo "🔍 System Status Check"
echo "====================="

echo "[1/5] Checking cluster..."
kubectl get nodes

echo "[2/5] Checking namespaces..."
kubectl get namespaces | grep -E "(gitlab|argocd|dev)"

echo "[3/5] Checking GitLab..."
kubectl get pods -n gitlab
kubectl get svc -n gitlab

echo "[4/5] Checking ArgoCD..."
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
kubectl get svc -n argocd

echo "[5/5] Testing connectivity..."
echo "GitLab: http://192.168.56.111:8080"
echo "ArgoCD: http://192.168.56.111:31080"

echo ""
echo "🔑 Get passwords:"
echo "GitLab: kubectl exec -n gitlab deployment/gitlab -- cat /etc/gitlab/initial_root_password | grep Password:"
echo "ArgoCD: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "✅ Verification complete!"