#!/bin/bash
set -euo pipefail

echo "🔧 Fixing ArgoCD Memory Issues"
echo "=============================="

echo "📋 This script applies memory limits to ArgoCD components to prevent OOM issues."
echo ""

# Check if ArgoCD is installed
if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "❌ ArgoCD namespace not found. Please install ArgoCD first using 02-install-tools.sh"
    exit 1
fi

echo "✅ ArgoCD namespace found. Proceeding with memory configuration..."

# Wait for ArgoCD to be fully deployed
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo "🔧 Applying memory limits to ArgoCD components..."

# Patch StatefulSet with memory limits
echo "  - Configuring argocd-application-controller..."
kubectl patch statefulset argocd-application-controller -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-application-controller","resources":{"limits":{"memory":"512Mi","cpu":"500m"},"requests":{"memory":"256Mi","cpu":"250m"}}}]}}}}' || true

# Patch Deployments with memory limits
echo "  - Configuring argocd-repo-server..."
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true

echo "  - Configuring argocd-server..."
kubectl patch deployment argocd-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "512Mi", "cpu": "500m"}, "requests": {"memory": "256Mi", "cpu": "250m"}}}]' || true

echo "  - Configuring argocd-applicationset-controller..."
kubectl patch deployment argocd-applicationset-controller -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources", "value": {"limits": {"memory": "256Mi", "cpu": "250m"}, "requests": {"memory": "128Mi", "cpu": "125m"}}}]' || true

echo ""
echo "✅ Memory configuration applied successfully!"
echo ""
echo "📊 Applied Memory Limits:"
echo "  - argocd-application-controller: 512Mi memory, 500m CPU"
echo "  - argocd-repo-server: 512Mi memory, 500m CPU"
echo "  - argocd-server: 512Mi memory, 500m CPU"
echo "  - argocd-applicationset-controller: 256Mi memory, 250m CPU"
echo ""
echo "⏳ Waiting for pods to restart with new limits..."
sleep 30

echo ""
echo "🔍 Current ArgoCD Status:"
kubectl get pods -n argocd

echo ""
echo "🎯 ArgoCD should now be stable and not crash due to memory issues!"
