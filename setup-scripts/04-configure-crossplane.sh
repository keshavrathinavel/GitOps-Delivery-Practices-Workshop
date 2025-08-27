#!/bin/bash
set -euo pipefail

echo "✈️ Configuring Crossplane for Infrastructure as Code..."

echo "Installing Crossplane AWS Provider (for future cloud resource provisioning)..."
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.47.1
EOF

echo "Installing PostgreSQL Composite Resource Definition..."
kubectl apply -f ../infra-manifests/crossplane/postgresql-definition.yaml

echo "✅ Crossplane configured for future infrastructure provisioning."
echo "⏳ Note: AWS provider will fail to connect without real credentials, but CRDs will be available."
echo "💡 This can be used for future workshops with real cloud infrastructure."
