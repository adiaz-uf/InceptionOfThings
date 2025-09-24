NAME = bonus-gitlab

all: up

up:
	vagrant up

down:
	vagrant destroy -f

re: down up

vm:
	vagrant ssh iot-gitlab

# Helper commands for development
verify:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/verify.sh"

configure:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/configure-gitlab.sh"

passwords:
	vagrant ssh iot-gitlab -c "echo 'GitLab root password:'; cat /tmp/gitlab-root-password.txt 2>/dev/null || echo 'Not available yet'"
	vagrant ssh iot-gitlab -c "echo 'ArgoCD admin password:'; cat /tmp/argocd-admin-password.txt 2>/dev/null || echo 'Not available yet'"

logs-gitlab:
	vagrant ssh iot-gitlab -c "kubectl logs -n gitlab -l app=webservice --tail=50"

logs-argocd:
	vagrant ssh iot-gitlab -c "kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50"

status:
	vagrant ssh iot-gitlab -c "kubectl get pods -A"

# Test all requirements
test:
	vagrant ssh iot-gitlab -c "bash /home/vagrant/scripts/test-requirements.sh"

.PHONY: all up down re vm verify configure passwords logs-gitlab logs-argocd status test