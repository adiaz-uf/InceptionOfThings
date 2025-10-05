NAME = p3

all: setup up

setup:
	@echo "Running setup script..."
	@cd $(shell pwd) && bash scripts/setup.sh

up:
	@echo "Running deployment script..."
	@cd $(shell pwd) && bash scripts/deploy.sh

clean:
	@echo "Destroying K3D cluster..."
	@k3d cluster delete mycluster || true

re: clean up

status:
	@echo "Cluster status:"
	@k3d cluster list
	@echo "\nKubernetes nodes:"
	@kubectl get nodes 2>/dev/null || echo "No cluster found"
	@echo "\nArgoCD pods:"
	@kubectl get pods -n argocd 2>/dev/null || echo "ArgoCD namespace not found"
	@echo "\nDev namespace pods:"
	@kubectl get pods -n dev 2>/dev/null || echo "Dev namespace not found"

password:
	@echo "ArgoCD admin password:"
	@kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" 2>/dev/null | base64 -d && echo || echo "ArgoCD not installed"

.PHONY: all setup up clean re status password
