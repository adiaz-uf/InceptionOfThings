NAME = bonus-gitlab

all: up

up:
	vagrant up

down:
	vagrant destroy -f

re: down up

vm:
	vagrant ssh iot-gitlab

sync:
	vagrant ssh iot-gitlab -c "kubectl apply -f confs/will-app.yaml"

# Essential commands
verify:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/verify.sh"

passwords:
	@echo "GitLab root password:"
	@vagrant ssh iot-gitlab -c "kubectl exec -n gitlab deployment/gitlab -- cat /etc/gitlab/initial_root_password 2>/dev/null | grep 'Password:' || echo 'Not available yet - GitLab still starting'"
	@echo ""
	@echo "ArgoCD admin password:"
	@vagrant ssh iot-gitlab -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo 'Not available yet'"

# Monitoring commands
logs-gitlab:
	vagrant ssh iot-gitlab -c "kubectl logs -n gitlab deployment/gitlab --tail=50"

logs-argocd:
	vagrant ssh iot-gitlab -c "kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50"

status:
	vagrant ssh iot-gitlab -c "kubectl get pods -A"

debug:
	vagrant ssh iot-gitlab -c "echo '=== CLUSTER STATUS ==='; kubectl get nodes"
	vagrant ssh iot-gitlab -c "echo '=== ALL PODS ==='; kubectl get pods -A"
	vagrant ssh iot-gitlab -c "echo '=== GITLAB PODS ==='; kubectl get pods -n gitlab"
	vagrant ssh iot-gitlab -c "echo '=== DEPLOYMENTS ==='; kubectl get deployments -n gitlab"
	vagrant ssh iot-gitlab -c "echo '=== EVENTS ==='; kubectl get events -n gitlab --sort-by='.lastTimestamp' | tail -10"


.PHONY: all up down re vm verify configure fix-gitlab passwords logs-gitlab logs-argocd status debug test sync