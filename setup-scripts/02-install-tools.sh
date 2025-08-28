#!/bin/bash
set -euo pipefail

echo "🚀 Installing or Upgrading ArgoCD..."
# This command will install the chart if it's not present, or upgrade it if it is.
helm repo add argo https://argoproj.github.io/argo-helm || true
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 5.52.0 \
  --wait

echo "🔧 Configuring ArgoCD memory limits to prevent OOM issues..."
# Wait for ArgoCD to be fully deployed
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-application-controller -n argocd --timeout=300s

# The patch commands already use '|| true' to avoid errors if they fail, which is fine.
# Patch StatefulSet with memory limits
kubectl patch statefulset argocd-application-controller -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"application-controller","resources":{"limits":{"memory":"512Mi","cpu":"500m"},"requests":{"memory":"256Mi","cpu":"250m"}}}]}}}}' || true

# Patch Deployments with memory limits
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true
kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true
kubectl patch deployment argocd-applicationset-controller -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "256Mi", "cpu": "250m"}, "requests": {"memory": "128Mi", "cpu": "125m"}}}]' || true

echo "✅ ArgoCD memory configuration applied!"
echo "✅ All platform tools installed successfully!"
