# inception-of-things

Kubernetes initiation project with K3s, K3d and Vagrant.

## Installation and Setup

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
```

## Part 3: K3d and Argo CD



# Team work 💪

This project was a team effort. You can checkout the team members here:

-   **Alejandro Díaz Ufano Pérez**
    -   [Github](https://github.com/adiaz-uf)
    -   [LinkedIn](https://www.linkedin.com/in/alejandro-d%C3%ADaz-35a996303/)
    -   [42 intra](https://profile.intra.42.fr/users/adiaz-uf)
-   **Alejandro Aparicio**
    -   [Github](https://github.com/magnitopic)
    -   [LinkedIn](https://www.linkedin.com/in/magnitopic/)
    -   [42 intra](https://profile.intra.42.fr/users/alaparic)
