# inception-of-things

Kubernetes initiation project with K3s, K3d and Vagrant.

## ⚙️ Installation and Setup

```bash
git clone https://github.com/adiaz-uf/InceptionOfThings.git
cd InceptionOfThings
```

> Install Vagrant and VirtualBox if you haven't already.

Vagrant installation example:

```bash
wget https://releases.hashicorp.com/vagrant/2.4.1/vagrant_2.4.1-1_amd64.deb
sudo apt install ./vagrant_2.4.1-1_amd64.deb
```

VirtualBox installation:

```bash
sudo apt install virtualbox
```

## Part 1: K3s and Vagrant

Sets up two machines running K3s, one as a server and the other as a worker.

```bash
cd  p1
make

# Connect to the K3s server
make s

# Connect to the K3s worker
make sw
```

## Part 2: K3s and three simple applications

Creates 3 web applications running on K3s in one virtual machine. You can access them depending on the _host_ used when making a request to the IP address 192.168.56.11. There is **app1.com**, **app2.com**, and by default **app3.com**.

```bash
cd p2
make

# Connect to the server
make s

# See the applications
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
curl -H "" http://192.168.56.110 # Default app (app3.com)
```

You can also choose to modify your `/etc/hosts` file to see the applications in a web browser.

## Part 3: K3d and Argo CD

Without using Vagrant, this part creates a K3d cluster and deploys Argo CD to manage git repositories.

```bash
cd p3
make
```

Una vez desplegado:

-   **ArgoCD**: http://localhost:31080
    -   User: `admin`
    -   Password: Run `make password` to get it
-   **Running application**: http://localhost:8888

## Bonus part: Argo CD and local Gitlab

The bonus of the project adds a local Gitlab instance and connects it to Argo CD. This way, any changes pushed to the Gitlab repository will be automatically deployed to the K3d cluster via Argo CD.

```bash
cd bonus
make
```

Once deployed:

-   **GitLab**: http://localhost:8080
    -   User: `root` + password (shown in terminal)
-   **ArgoCD**: http://localhost:31080
    -   User: `admin`
    -   Password: Run `make password` to get it

# 🗂️ Project structure

```
.
├── bonus
│   ├── confs
│   │   ├── argocd-server.yaml
│   │   ├── gitlab-simple.yaml
│   │   └── will-app.yaml
│   ├── gitlab
│   │   └── app-manifests
│   │       ├── deployment.yaml
│   │       └── README.md
│   ├── Makefile
│   └── scripts
│       ├── cleanup.sh
│       ├── deploy.sh
│       ├── setup.sh
│       └── verify.sh
├── p1
│   ├── Makefile
│   ├── scripts
│   │   ├── k3s-server.sh
│   │   └── k3s-worker.sh
│   └── Vagrantfile
├── p2
│   ├── confs
│   │   ├── app1.yaml
│   │   ├── app2.yaml
│   │   ├── app3.yaml
│   │   └── ingress.yaml
│   ├── Makefile
│   ├── scripts
│   │   ├── deploy.sh
│   │   └── setup.sh
│   └── Vagrantfile
└── p3
    ├── confs
    │   ├── argocd-server.yaml
    │   └── wil-app.yaml
    ├── Makefile
    └── scripts
        ├── deploy.sh
        └── setup.sh
```

# 💪 Team work

This project was a team effort. You can checkout the team members here:

-   **Alejandro Díaz Ufano Pérez**
    -   [Github](https://github.com/adiaz-uf)
    -   [LinkedIn](https://www.linkedin.com/in/alejandro-d%C3%ADaz-35a996303/)
    -   [42 intra](https://profile.intra.42.fr/users/adiaz-uf)
-   **Alejandro Aparicio**
    -   [Github](https://github.com/magnitopic)
    -   [LinkedIn](https://www.linkedin.com/in/magnitopic/)
    -   [42 intra](https://profile.intra.42.fr/users/alaparic)
