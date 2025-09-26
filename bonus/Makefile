NAME = bonus-gitlab

all: up

up:
	vagrant up

down:
	vagrant destroy -f

re: down up

vm:
	vagrant ssh iot-gitlab

# Essential commands
verify:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/verify.sh"

configure:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/configure-gitlab.sh"

passwords:
	vagrant ssh iot-gitlab -c "echo 'GitLab root password:'; cat /tmp/gitlab-root-password.txt 2>/dev/null || echo 'Not available yet'"
	vagrant ssh iot-gitlab -c "echo 'ArgoCD admin password:'; cat /tmp/argocd-admin-password.txt 2>/dev/null || echo 'Not available yet'"

# Monitoring commands
logs-gitlab:
	vagrant ssh iot-gitlab -c "kubectl logs -n gitlab -l app=webservice --tail=50"

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

# Test all requirements
test:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/test-requirements.sh"

.PHONY: all up down re vm verify configure fix-gitlab passwords logs-gitlab logs-argocd status debug test