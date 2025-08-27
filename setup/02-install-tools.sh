#!/bin/bash
set -euo pipefail

echo "🚀 Installing ArgoCD..."
kubectl create namespace argocd || true
helm repo add argo https://argoproj.github.io/argo-helm || true
helm install argocd argo/argo-cd -n argocd --version 5.52.0 --wait

echo "🚀 Installing Crossplane..."
kubectl create namespace crossplane-system || true
helm repo add crossplane-stable https://charts.crossplane.io/stable || true
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.14.5 --wait

echo "🚀 Installing Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com || true
helm install vault hashicorp/vault --namespace default --set "server.dev.enabled=true" --wait

echo "🚀 Installing Vault Secrets Operator..."
helm install vault-secrets-operator hashicorp/vault-secrets-operator --namespace default --wait

echo "✅ All platform tools installed successfully!"
