#!/bin/bash
set -euo pipefail

CLUSTER_NAME="gitops-workshop"

echo "🔥 Creating kind cluster: ${CLUSTER_NAME}"

kind create cluster --name "${CLUSTER_NAME}" --config=../kind-cluster-config.yaml

echo "✅ Cluster '${CLUSTER_NAME}' created successfully."
echo "👉 Your kubectl context is now set to 'kind-${CLUSTER_NAME}'"
