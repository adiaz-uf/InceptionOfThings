# InceptionOfThings - P3 (ArgoCD Deployment)

Este proyecto despliega una aplicación usando ArgoCD en un clúster K3D local.

## Prerequisitos

- Sistema Linux (Debian/Ubuntu o similar)
- Acceso a sudo
- Conexión a Internet

## Instalación

### 1. Instalar dependencias

```bash
make setup
```

Este comando instalará:
- Docker
- K3D
- kubectl

**Nota:** Si Docker se instaló por primera vez, necesitarás cerrar sesión y volver a iniciarla, o ejecutar `newgrp docker` para usar Docker sin sudo.

### 2. Desplegar el clúster y ArgoCD

```bash
make deploy
```

Este comando:
- Crea un clúster K3D llamado "mycluster"
- Instala ArgoCD
- Despliega la aplicación desde el repositorio GitHub

## Comandos Útiles

- `make setup` - Instala todas las dependencias necesarias
- `make deploy` - Despliega el clúster y la aplicación
- `make clean` - Elimina el clúster K3D
- `make re` - Limpia y vuelve a desplegar
- `make status` - Muestra el estado del clúster y los pods
- `make password` - Obtiene la contraseña de admin de ArgoCD

## Acceso a los Servicios

Una vez desplegado:

- **ArgoCD Web UI**: http://localhost:31080
  - Usuario: `admin`
  - Contraseña: Ejecuta `make password` para obtenerla

- **Aplicación desplegada**: http://localhost:8888

## Estructura del Proyecto

```
.
├── Makefile              # Comandos make para gestionar el proyecto
├── README.md             # Este archivo
├── confs/                # Archivos de configuración de Kubernetes
│   ├── argocd-server.yaml
│   └── wil-app.yaml
└── scripts/              # Scripts de configuración y despliegue
    ├── setup.sh
    └── deploy.sh
```

## Troubleshooting

### Docker requiere sudo
Si acabas de instalar Docker:
```bash
newgrp docker
```

O cierra sesión y vuelve a iniciarla.

### Ver logs de ArgoCD
```bash
kubectl logs -n argocd deployment/argocd-server
```

### Reiniciar desde cero
```bash
make clean
make deploy
```
