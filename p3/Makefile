NAME = p3

all: up

up:
	vagrant up

down:
	vagrant destroy -f

re: down up

vm:
	vagrant ssh iot-argocd

.PHONY: all up down s sw