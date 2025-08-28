#!/bin/bash
set -euo pipefail

echo "🔄 Starting Self-Healing Infrastructure Demo..."

NAMESPACE="staging"
RESOURCE_PATH="../infra-manifests/apps/db-pinger/overlays/staging"

# Function to apply resources
apply_resources() {
    echo "📦 Applying resources to $NAMESPACE namespace..."
    kubectl apply -k "$RESOURCE_PATH"
}

# Function to check if deployment exists
check_deployment() {
    kubectl get deployment db-pinger -n "$NAMESPACE" >/dev/null 2>&1
}

# Function to check if pod is running
check_pod_running() {
    kubectl get pods -n "$NAMESPACE" -l app=db-pinger --field-selector=status.phase=Running | grep -q db-pinger
}

echo "✅ Initial resource deployment..."
apply_resources

echo "🔍 Monitoring for resource changes..."
echo "💡 Try deleting the deployment with: kubectl delete deployment db-pinger -n staging"
echo "💡 Or delete a pod with: kubectl delete pod <pod-name> -n staging"
echo "💡 Press Ctrl+C to stop monitoring"

# Monitor loop
while true; do
    if ! check_deployment; then
        echo "🚨 Deployment missing! Recreating..."
        apply_resources
        sleep 5
    elif ! check_pod_running; then
        echo "⚠️  No running pods found! Checking deployment status..."
        kubectl get pods -n "$NAMESPACE" -l app=db-pinger
        sleep 5
    else
        echo "✅ Resources healthy - $(date)"
        sleep 10
    fi
done
