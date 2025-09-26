external_url 'http://192.168.56.111:8080'
gitlab_rails['gitlab_host'] = '192.168.56.111'
gitlab_rails['gitlab_port'] = 8080
gitlab_rails['gitlab_https'] = false
gitlab_rails['gitlab_ssh_host'] = '192.168.56.111'
gitlab_rails['gitlab_ssh_port'] = 22

# Disable HTTPS redirect
nginx['redirect_http_to_https'] = false
nginx['listen_port'] = 8080
nginx['listen_https'] = false

# CSRF settings
gitlab_rails['rack_attack_git_basic_auth'] = {
  'enabled' => false
}

# Allow all IPs
gitlab_rails['allowed_hosts'] = ['192.168.56.111', 'localhost']
