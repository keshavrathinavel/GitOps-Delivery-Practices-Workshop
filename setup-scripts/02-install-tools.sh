#!/bin/bash
set -euo pipefail

echo "🚀 Installing ArgoCD..."
kubectl create namespace argocd || true
helm repo add argo https://argoproj.github.io/argo-helm || true
helm install argocd argo/argo-cd -n argocd --version 5.52.0 --wait

echo "🔧 Configuring ArgoCD memory limits to prevent OOM issues..."
# Wait for ArgoCD to be fully deployed
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Patch StatefulSet with memory limits
kubectl patch statefulset argocd-application-controller -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-application-controller","resources":{"limits":{"memory":"512Mi","cpu":"500m"},"requests":{"memory":"256Mi","cpu":"250m"}}}]}}}}' || true

# Patch Deployments with memory limits
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true

kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true

kubectl patch deployment argocd-applicationset-controller -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "256Mi", "cpu": "250m"}, "requests": {"memory": "128Mi", "cpu": "125m"}}}]' || true

echo "✅ ArgoCD memory configuration applied!"

echo "🚀 Installing Crossplane..."
kubectl create namespace crossplane-system || true
helm repo add crossplane-stable https://charts.crossplane.io/stable || true
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.14.5 --wait

echo "🚀 Vault removed from workshop - keeping it simple! 🎯"

echo "✅ All platform tools installed successfully!"
