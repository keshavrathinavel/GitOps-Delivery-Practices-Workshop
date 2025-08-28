#!/bin/bash

cd ..

echo "👉 Creating staging and production namespaces..."
kubectl create ns staging || true; kubectl create ns production || true

echo "👉 Creating argocd applications..."
kubectl apply -f argocd-applications.yaml
