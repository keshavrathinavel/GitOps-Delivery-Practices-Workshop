#!/bin/bash
set -euo pipefail

echo "✈️ Configuring Crossplane..."

# Note: For a local demo, we use dummy credentials.
# Crossplane controllers will fail to connect to AWS, but they will still
# create the Composite Resources and Claims, which is sufficient to
# demonstrate the GitOps workflow with ArgoCD.

AWS_ACCESS_KEY_ID="DUMMY_KEY_ID"
AWS_SECRET_ACCESS_KEY="DUMMY_SECRET_KEY"

echo "Creating Kubernetes secret for AWS provider..."
kubectl create secret generic aws-secret -n crossplane-system \
  --from-literal=credentials="[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Crossplane AWS Provider..."
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.47.1
EOF

echo "✅ Crossplane configured."
echo "⏳ Note: It may take a few minutes for the AWS provider to become healthy."
