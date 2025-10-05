# Bonus: GitLab + ArgoCD CI/CD Pipeline

Este proyecto despliega un entorno completo de CI/CD usando GitLab y ArgoCD directamente en tu máquina Linux.

## 📋 Requisitos Previos

- **Sistema Operativo**: Linux (Ubuntu/Debian recomendado)
- **Recursos**: 
  - 4GB RAM mínimo (8GB recomendado)
  - 20GB espacio en disco
  - CPU de 2 núcleos mínimo

## 🚀 Instalación

### 1. Instalar Prerequisitos (primera vez)

```bash
make setup
```

Este comando instalará:
- Docker
- K3d (Kubernetes en Docker)
- kubectl

**Nota**: Después de la instalación, necesitarás cerrar sesión y volver a entrar para que los cambios de grupo de Docker surtan efecto, o ejecutar:

```bash
newgrp docker
```

### 2. Desplegar el Proyecto

```bash
make up
```

Este comando:
- Crea un cluster K3D con los puertos mapeados
- Despliega GitLab
- Despliega ArgoCD
- Configura los servicios

El proceso puede tomar **5-10 minutos** en la primera ejecución mientras GitLab se inicializa.

## 🔑 Acceso a los Servicios

### URLs:
- **GitLab**: http://localhost:8080
- **ArgoCD**: http://localhost:31080

### Obtener Credenciales:

```bash
make passwords
```

Esto mostrará:
- Usuario GitLab: `root` + contraseña
- Usuario ArgoCD: `admin` + contraseña

## 📊 Comandos Disponibles

### Gestión del Cluster

```bash
make up          # Desplegar todo el entorno
make down        # Destruir el cluster
make re          # Reiniciar (down + up)
make clean       # Limpiar todo incluyendo configuraciones
```

### Monitoreo y Debug

```bash
make verify      # Verificar el estado del sistema
make status      # Ver todos los pods
make debug       # Información detallada de debug
make passwords   # Mostrar credenciales
```

### Logs

```bash
make logs-gitlab  # Ver logs de GitLab
make logs-argocd  # Ver logs de ArgoCD
```

### Sincronización

```bash
make sync        # Aplicar/actualizar la aplicación de ArgoCD
```

## 📝 Flujo de Trabajo

1. **Iniciar el entorno**:
   ```bash
   make up
   ```

2. **Obtener credenciales**:
   ```bash
   make passwords
   ```

3. **Configurar GitLab**:
   - Accede a http://localhost:8080
   - Login como `root` con la contraseña obtenida
   - Crea un nuevo proyecto público llamado `wil-app`
   - Sube los archivos del directorio `gitlab/app-manifests/`

4. **Configurar ArgoCD**:
   ```bash
   make sync
   ```

5. **Verificar el despliegue**:
   - Accede a ArgoCD en http://localhost:31080
   - Login como `admin`
   - Verifica que la aplicación `wil-app` se sincronice correctamente

## 🛠️ Troubleshooting

### GitLab no inicia

```bash
# Ver logs
make logs-gitlab

# Ver estado de los pods
kubectl get pods -n gitlab
```

### ArgoCD no se conecta a GitLab

Verifica que:
1. GitLab esté corriendo: `kubectl get pods -n gitlab`
2. El proyecto `wil-app` exista en GitLab
3. El proyecto sea público o tenga las credenciales configuradas

### Reiniciar todo

```bash
make clean
make up
```

## 🗂️ Estructura del Proyecto

```
bonus/
├── Makefile                    # Comandos principales
├── scripts/
│   ├── setup.sh               # Instalación de prerequisitos
│   ├── deploy.sh              # Script de despliegue
│   └── verify.sh              # Verificación del sistema
├── confs/
│   ├── gitlab-simple.yaml     # Configuración de GitLab
│   ├── argocd-server.yaml     # Configuración de ArgoCD
│   └── will-app.yaml          # Aplicación de ArgoCD
└── gitlab/
    └── app-manifests/         # Manifiestos de la aplicación
        └── deployment.yaml
```

## 🔒 Seguridad

**Advertencia**: Esta configuración es para desarrollo/pruebas. Para producción:
- Usa HTTPS
- Configura autenticación adecuada
- Usa secrets de Kubernetes para credenciales
- Configura límites de recursos apropiados
- Habilita backups

## 🧹 Limpieza

Para eliminar completamente el entorno:

```bash
make clean
```

Esto eliminará:
- El cluster K3D
- Configuraciones de kubeconfig
- Archivos temporales de contraseñas

## 📚 Referencias

- [K3d Documentation](https://k3d.io/)
- [GitLab Documentation](https://docs.gitlab.com/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
