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
