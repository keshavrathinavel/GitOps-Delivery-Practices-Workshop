#!/bin/bash
set -euo pipefail

CLUSTER_NAME="gitops-workshop"

echo "🧹 Starting comprehensive cleanup of resources..."

# Function to check if cluster exists
cluster_exists() {
    kind get clusters | grep -q "${CLUSTER_NAME}" 2>/dev/null
}

# Function to check if kubectl context is set to our cluster
context_is_set() {
    kubectl config current-context 2>/dev/null | grep -q "kind-${CLUSTER_NAME}"
}

# Function to check if we can connect to the cluster
cluster_accessible() {
    kubectl get nodes >/dev/null 2>&1
}

# Check if cluster exists first
if ! cluster_exists; then
    echo "ℹ️  Kind cluster '${CLUSTER_NAME}' not found or already deleted."
    echo "🧹 Cleaning up kubectl context..."
    kubectl config delete-context "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Context 'kind-${CLUSTER_NAME}' not found"
    kubectl config delete-cluster "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Cluster 'kind-${CLUSTER_NAME}' not found"
    echo "🧹 Cleaning up any remaining Docker resources..."
    docker system prune -f --filter "label=io.x-k8s.kind.cluster=${CLUSTER_NAME}" 2>/dev/null || true
    echo "✅ Cleanup completed successfully!"
    echo "🎉 All resources have been removed."
    exit 0
fi

# Check if we can access the cluster
if ! cluster_accessible; then
    echo "⚠️  Warning: Cannot connect to cluster. It may be stopped or not accessible."
    echo "   Proceeding with cluster deletion and context cleanup..."
    echo "🗑️  Removing kind cluster..."
    kind delete cluster --name "${CLUSTER_NAME}"
    echo "🧹 Cleaning up kubectl context..."
    kubectl config delete-context "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Context 'kind-${CLUSTER_NAME}' not found"
    kubectl config delete-cluster "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Cluster 'kind-${CLUSTER_NAME}' not found"
    echo "🧹 Cleaning up any remaining Docker resources..."
    docker system prune -f --filter "label=io.x-k8s.kind.cluster=${CLUSTER_NAME}" 2>/dev/null || true
    echo "✅ Cleanup completed successfully!"
    echo "🎉 All resources have been removed."
    exit 0
fi

# Check if we're connected to the right cluster
if ! context_is_set; then
    echo "⚠️  Warning: kubectl context is not set to kind-${CLUSTER_NAME}"
    echo "   Current context: $(kubectl config current-context 2>/dev/null || echo 'none')"
    echo "   Proceeding with cleanup anyway..."
fi

echo "🗑️  Removing ArgoCD Applications..."
kubectl delete application db-pinger-staging -n argocd --ignore-not-found=true
kubectl delete application db-pinger-production -n argocd --ignore-not-found=true

echo "🗑️  Removing application resources..."
kubectl delete -k ../infra-manifests/apps/db-pinger/overlays/staging --ignore-not-found=true
kubectl delete -k ../infra-manifests/apps/db-pinger/overlays/production --ignore-not-found=true

echo "🗑️  Removing database resources..."
kubectl delete -f ../infra-manifests/database/postgresql.yaml --ignore-not-found=true
kubectl delete -f ../infra-manifests/database/secrets.yaml --ignore-not-found=true

echo "🗑️  Removing namespaces..."
kubectl delete namespace staging --ignore-not-found=true
kubectl delete namespace production --ignore-not-found=true

echo "🗑️  Removing ArgoCD..."
helm uninstall argocd -n argocd --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true

echo "🗑️  Cleaning up any remaining resources..."
# Remove any remaining deployments, statefulsets, services, etc.
kubectl delete deployment --all --all-namespaces --ignore-not-found=true
kubectl delete statefulset --all --all-namespaces --ignore-not-found=true
kubectl delete service --all --all-namespaces --ignore-not-found=true
kubectl delete configmap --all --all-namespaces --ignore-not-found=true
kubectl delete secret --all --all-namespaces --ignore-not-found=true
kubectl delete serviceaccount --all --all-namespaces --ignore-not-found=true
kubectl delete persistentvolumeclaim --all --all-namespaces --ignore-not-found=true
kubectl delete persistentvolume --all --ignore-not-found=true

echo "🗑️  Removing kind cluster..."
if cluster_exists; then
    kind delete cluster --name "${CLUSTER_NAME}"
    echo "✅ Kind cluster '${CLUSTER_NAME}' deleted successfully."
else
    echo "ℹ️  Kind cluster '${CLUSTER_NAME}' not found or already deleted."
fi

echo "🧹 Cleaning up kubectl context..."
kubectl config delete-context "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Context 'kind-${CLUSTER_NAME}' not found"
kubectl config delete-cluster "kind-${CLUSTER_NAME}" 2>/dev/null || echo "Cluster 'kind-${CLUSTER_NAME}' not found"

echo "🧹 Cleaning up any remaining Docker resources..."
# Remove any dangling images or containers related to the workshop
docker system prune -f --filter "label=io.x-k8s.kind.cluster=${CLUSTER_NAME}" 2>/dev/null || true

echo "✅ Cleanup completed successfully!"
echo "🎉 All resources have been removed."
echo "   - ArgoCD applications and namespace"
echo "   - Database resources (PostgreSQL, secrets)"
echo "   - Application deployments (db-pinger)"
echo "   - Namespaces (staging, production)"
echo "   - Kind cluster and kubectl context"
echo "   - Docker resources"

echo ""
echo "💡 To start fresh, run the setup scripts again:"
echo "   ./setup-scripts/01-create-cluster.sh"
echo "   ./setup-scripts/02-install-tools.sh"
echo "   ./setup-scripts/03-setup-database.sh"
