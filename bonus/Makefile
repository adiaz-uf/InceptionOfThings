NAME = bonus-gitlab

all: setup up

# Main deployment
up:
	@echo "🚀 Starting deployment..."
	@bash scripts/deploy.sh

# Setup prerequisites (Docker, K3d, kubectl)
setup:
	@echo "📦 Installing prerequisites..."
	@bash scripts/setup.sh

# Teardown
down:
	@echo "🔽 Destroying cluster..."
	@k3d cluster delete gitlab-cluster || true

# Full reset
re: down up

# Sync ArgoCD application
sync:
	@kubectl apply -f confs/will-app.yaml

# Essential commands
verify:
	@bash scripts/verify.sh

passwords:
	@echo "🔑 GitLab root password:"
	@kubectl exec -n gitlab deployment/gitlab -- cat /etc/gitlab/initial_root_password 2>/dev/null | grep 'Password:' || echo 'Not available yet - GitLab still starting'
	@echo ""
	@echo "🔑 ArgoCD admin password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo 'Not available yet'
	@echo ""

# Monitoring commands
logs-gitlab:
	@kubectl logs -n gitlab deployment/gitlab --tail=50

logs-argocd:
	@kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50

status:
	@kubectl get pods -A

debug:
	@echo '=== CLUSTER STATUS ==='
	@kubectl get nodes
	@echo ""
	@echo '=== ALL PODS ==='
	@kubectl get pods -A
	@echo ""
	@echo '=== GITLAB PODS ==='
	@kubectl get pods -n gitlab
	@echo ""
	@echo '=== DEPLOYMENTS ==='
	@kubectl get deployments -n gitlab
	@echo ""
	@echo '=== EVENTS ==='
	@kubectl get events -n gitlab --sort-by='.lastTimestamp' | tail -10

# Cleanup
clean: down
	@echo "🧹 Cleaning up..."
	@rm -rf ~/.kube/config
	@rm -f /tmp/gitlab-root-password.txt /tmp/argocd-admin-password.txt

.PHONY: all up setup down re verify passwords logs-gitlab logs-argocd status debug sync clean
