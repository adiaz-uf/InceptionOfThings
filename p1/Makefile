NAME = p1

all: up clean-linux

prepare:
	@mkdir -p ./confs

up: prepare
	vagrant up

down:
	vagrant destroy -f

re: down up

clean-windows:
	powershell -Command "if (Test-Path ./confs/token) { Remove-Item ./confs/token }"

clean-linux:
	# ${RM} ./confs/token

s:
	vagrant ssh adiaz-ufS

sw:
	vagrant ssh alaparicSW

.PHONY: all up down re s sw prepare clean-linux clean-windows
