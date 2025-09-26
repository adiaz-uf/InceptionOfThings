# IoT Bonus - GitLab Integration with ArgoCD

This bonus part adds GitLab to the infrastructure from Part 3, creating a complete GitOps workflow with local GitLab, ArgoCD, and Kubernetes.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     GitLab      │    │     ArgoCD      │    │   Application   │
│   (Source)      │───▶│   (Deploy)      │───▶│     (K8s)       │
│ CI/CD Pipeline  │    │  Auto Sync      │    │  wil-playground │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Components

- **K3D Cluster**: Lightweight Kubernetes cluster
- **GitLab CE**: Local GitLab instance with CI/CD
- **ArgoCD**: GitOps continuous deployment
- **Sample App**: wil42/playground (v1/v2)
- **Namespaces**: `gitlab`, `argocd`, `dev`

## 🚀 Quick Start

### 1. Start the Environment
```bash
cd bonus/
make up
```

### 2. Verify Installation
```bash
make verify
```

### 3. Get Access Credentials
```bash
make passwords
```

### 4. Configure GitLab Project
```bash
make configure
```

## 🔧 Manual Setup Process

### Step 1: Access GitLab
- URL: http://192.168.56.111:8080
- Username: `root`
- Password: Get with `make passwords`

### Step 2: Create Project
1. Click "New project" → "Create blank project"
2. Project name: `wil-app`
3. Visibility: Public
4. Initialize with README: ✓
5. Click "Create project"

### Step 3: Upload Application Files
Navigate to your project and upload these files from `gitlab/app-manifests/`:
- `deployment.yaml` - Kubernetes manifests
- `.gitlab-ci.yml` - CI/CD pipeline
- `README.md` - Project documentation

Or use git:
```bash
# Inside the VM
vagrant ssh iot-gitlab
git clone http://gitlab.192.168.56.111:8080/root/wil-app.git
cd wil-app
cp /home/vagrant/gitlab/app-manifests/* .
git add .
git config user.name "Administrator"
git config user.email "admin@example.com"
git commit -m "Add application manifests"
git push origin main
```

### Step 4: Deploy ArgoCD Application
```bash
# Inside the VM
kubectl apply -f /home/vagrant/confs/will-app.yaml
```

## 🧪 Testing the GitOps Workflow

### 1. Access ArgoCD
- URL: http://192.168.56.111:31080
- Username: `admin`
- Password: Get with `make passwords`

### 2. Verify Application Sync
Check that the `wil-app` application appears in ArgoCD and syncs successfully.

### 3. Test Version Switching
1. In GitLab, go to CI/CD → Pipelines
2. Run the `update-manifest` job manually
3. This switches between v1 and v2
4. Watch ArgoCD auto-sync the changes
5. Test: `curl http://192.168.56.111:30888/`

### Expected Output:
- v1: `{"status":"ok", "message": "v1"}`
- v2: `{"status":"ok", "message": "v2"}`

## 🛠️ Available Commands

```bash
make up          # Start the environment
make down        # Destroy the environment
make re          # Restart (down + up)
make vm          # SSH into the VM
make verify      # Verify system status
make configure   # Show configuration guide
make passwords   # Show access passwords
make status      # Show all pods status
make logs-gitlab # Show GitLab logs
make logs-argocd # Show ArgoCD logs
```

## 📁 File Structure

```
bonus/
├── Vagrantfile              # VM configuration
├── Makefile                 # Helper commands
├── scripts/
│   ├── setup.sh            # Install tools (Docker, K3d, kubectl, Helm)
│   ├── deploy.sh           # Deploy GitLab + ArgoCD
│   ├── configure-gitlab.sh # GitLab setup helper
│   └── verify.sh           # System verification
├── confs/
│   ├── argocd-server.yaml  # ArgoCD service config
│   └── will-app.yaml       # ArgoCD application config
└── gitlab/
    ├── values.yaml         # GitLab Helm values
    └── app-manifests/      # Sample application
        ├── deployment.yaml # Kubernetes manifests
        ├── .gitlab-ci.yml  # CI/CD pipeline
        └── README.md       # Project docs
```

## 🔧 Resource Requirements

- **Memory**: 4GB (VM gets 4GB, GitLab needs ~2GB)
- **CPU**: 2 cores minimum
- **Disk**: ~10GB for GitLab data
- **Network**: Private network 192.168.56.111

## 🎯 Key Features

### GitLab Features
- Complete CE installation with Helm
- Built-in CI/CD with GitLab Runner  
- Private Docker registry
- Git repository hosting
- Issue tracking and project management

### ArgoCD Integration
- Automatic sync from GitLab repository
- Real-time deployment status
- Rollback capabilities
- Multi-environment support

### Application Management
- Version switching via CI/CD
- Automated deployments
- Health checking
- Service exposure

## 🐛 Troubleshooting

### GitLab Taking Too Long to Start
```bash
make logs-gitlab
kubectl get pods -n gitlab
```

### ArgoCD Not Syncing
```bash
make logs-argocd
kubectl get applications -n argocd
```

### Application Not Accessible
```bash
kubectl get pods -n dev
kubectl get svc -n dev
```

### Memory Issues
- GitLab needs significant memory
- Monitor with: `vagrant ssh iot-gitlab -c "free -h"`
- Restart if needed: `make re`

## 📚 Learning Objectives

By completing this bonus, you'll understand:

- **GitOps Workflow**: Source → CI/CD → Deployment
- **GitLab Administration**: User management, projects, CI/CD
- **ArgoCD Operations**: Application management, sync policies
- **Kubernetes Integration**: Namespaces, services, deployments
- **Container Management**: Image versioning, registry integration

## ✅ Verification Checklist

- [ ] VM starts successfully
- [ ] GitLab web UI accessible
- [ ] ArgoCD web UI accessible  
- [ ] GitLab project created
- [ ] Application manifests uploaded
- [ ] ArgoCD application synced
- [ ] Application accessible at port 30888
- [ ] CI/CD pipeline can switch versions
- [ ] ArgoCD auto-syncs changes
- [ ] Both v1 and v2 work correctly

## 📖 References

- [GitLab CE Documentation](https://docs.gitlab.com/ee/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [K3D Documentation](https://k3d.io/)
- [Helm Charts](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)