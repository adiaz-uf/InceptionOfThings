BBLU		=	\033[1;34m
BGREEN		=	\033[1;32m
BRED		=	\033[1;31m
BLU			=	\033[0;34m
GRN			=	\033[0;32m
RED			=	\033[0;31m
RST			=	\033[0m

NAME = p1

all: up clean-windows

up:
	vagrant up

down:
	vagrant destroy -f

clean-windows:
	powershell -Command "if (Test-Path ./confs/token) { Remove-Item ./confs/token }"

clean-linux:
	# ${RM} ./confs/token

s:
	vagrant ssh adiaz-ufS

sw:
	vagrant ssh alaparicSW

.PHONY: all up down s sw