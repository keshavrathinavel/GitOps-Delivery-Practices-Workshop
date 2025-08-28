#!/bin/bash

cd ..

echo "👉 Creating staging and production namespaces. IGNORE ERRORS if namespace already exist..."
kubectl create ns staging || true; kubectl create ns production || true

echo "👉 Creating argocd applications..."
kubectl apply -f argocd-applications.yaml
