# Sample Application Repository for GitLab + ArgoCD Integration

This repository contains the Kubernetes manifests for the Wil Playground application that will be deployed using ArgoCD and managed through GitLab CI/CD.

## Files Structure

- `deployment.yaml` - Kubernetes deployment and service manifests
- `.gitlab-ci.yml` - GitLab CI/CD pipeline configuration
- `README.md` - This file

## Application Details

- **Image**: wil42/playground (v1 and v2 available)
- **Port**: 8888
- **Namespace**: dev

## CI/CD Workflow

1. **Test Stage**: Basic validation of the application
2. **Build Stage**: Updates the application version in deployment.yaml
3. **Deploy Stage**: Triggers ArgoCD sync (automated)

## Usage

1. Make changes to the application configuration
2. Push to the main branch
3. GitLab CI/CD pipeline will run automatically
4. Use the manual "update-manifest" job to switch between v1 and v2
5. ArgoCD will automatically deploy the changes

## Version Management

The pipeline can switch between two versions:
- `wil42/playground:v1` - Returns `{"status":"ok", "message": "v1"}`
- `wil42/playground:v2` - Returns `{"status":"ok", "message": "v2"}`

Test the application:
```bash
curl http://192.168.56.111:30888/
```