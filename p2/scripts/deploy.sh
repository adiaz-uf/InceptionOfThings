#!/bin/bash
set -e

echo "[+] Application Deployment..."
kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

echo "[✔] Apps deployed"
kubectl get pods
kubectl get svc
kubectl get ingress

#curl -H "Host: app1.com" http://192.168.56.110
#curl -H "Host: app2.com" http://192.168.56.110
#curl -H "Host: app3.com" http://192.168.56.110
#curl -H "" http://192.168.56.110
