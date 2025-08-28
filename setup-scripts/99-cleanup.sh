#!/bin/bash
set -euo pipefail

CLUSTER_NAME="gitops-workshop"

echo "🧹 Starting comprehensive cleanup of resources..."

# Function to check if cluster exists
cluster_exists() {
    kind get clusters | grep -q "^${CLUSTER_NAME}$"
}

if ! cluster_exists; then
    echo "ℹ️  Kind cluster '${CLUSTER_NAME}' not found. Cleaning up any residual configs."
    kubectl config delete-context "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    kubectl config delete-cluster "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    echo "✅ Cleanup complete."
    exit 0
fi

if ! kubectl get nodes >/dev/null 2>&1; then
    echo "⚠️  Cannot connect to cluster. Deleting Kind cluster directly."
    kind delete cluster --name "${CLUSTER_NAME}"
    kubectl config delete-context "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    kubectl config delete-cluster "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    echo "✅ Cleanup complete."
    exit 0
fi

# This is crucial for ensuring ArgoCD applications delete immediately.
echo "🧹 Removing finalizers from ArgoCD Applications to ensure clean removal..."
for app in $(kubectl get applications -n argocd -o name --ignore-not-found=true); do
    echo "  - Patching ${app}..."
    kubectl patch "${app}" -n argocd --type=merge -p '{"metadata":{"finalizers":[]}}' >/dev/null 2>&1 || true
done

echo "🗑️  Removing ArgoCD Applications..."
kubectl delete application --all -n argocd --ignore-not-found=true

# Removing manifests and namespaces as before
echo "🗑️  Removing application resources from manifests..."
kubectl delete -k ../infra-manifests/apps/db-pinger/overlays/staging --ignore-not-found=true
kubectl delete -k ../infra-manifests/apps/db-pinger/overlays/production --ignore-not-found=true

echo "🗑️  Removing database resources from manifests..."
kubectl delete -f ../infra-manifests/database/postgresql.yaml --ignore-not-found=true
kubectl delete -f ../infra-manifests/database/secrets.yaml --ignore-not-found=true

# This prevents namespaces from getting stuck in 'Terminating' state.
force_delete_namespace() {
    local ns="$1"
    echo "🧹 Force-purging namespace: ${ns}"
    kubectl get namespace "${ns}" >/dev/null 2>&1 || return 0
    kubectl api-resources --verbs=list --namespaced=true -o name \
      | xargs -n 1 -I {} sh -c "kubectl get {} -n ${ns} --ignore-not-found -o name | xargs -r -I '%%' kubectl patch '%%' -n ${ns} -p '{\"metadata\":{\"finalizers\":[]}}' --type=merge >/dev/null 2>&1 || true"
    kubectl delete namespace "${ns}" --ignore-not-found=true
}

force_delete_namespace "staging"
force_delete_namespace "production"

echo "🗑️  Uninstalling ArgoCD Helm release..."
helm uninstall argocd -n argocd --ignore-not-found=true
echo "🗑️ Purging ArgoCD resources..."
kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io

# Also purge the argocd namespace to be absolutely sure
force_delete_namespace "argocd"

echo "🗑️  Deleting kind cluster..."
kind delete cluster --name "${CLUSTER_NAME}"

echo "🧹 Cleaning up kubectl context..."
kubectl config delete-context "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
kubectl config delete-cluster "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true

echo "🧹 Cleaning up any remaining Docker resources..."
docker system prune -f --filter "label=io.x-k8s.kind.cluster=${CLUSTER_NAME}" 2>/dev/null || true

echo "✅ Comprehensive cleanup completed successfully!"
echo "🎉 All workshop resources have been fully purged."
