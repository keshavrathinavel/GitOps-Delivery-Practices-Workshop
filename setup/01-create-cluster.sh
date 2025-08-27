#!/bin/bash
set -euo pipefail

CLUSTER_NAME="gitops-workshop"

echo "🔥 Creating kind cluster: ${CLUSTER_NAME}"

cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
EOF

echo "✅ Cluster '${CLUSTER_NAME}' created successfully."
echo "👉 Your kubectl context is now set to 'kind-${CLUSTER_NAME}'"
