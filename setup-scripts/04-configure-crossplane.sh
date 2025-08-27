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

echo "Installing PostgreSQL Composite Resource Definition..."
kubectl apply -f ../infra-manifests/crossplane/postgresql-definition.yaml

echo "Creating mock PostgreSQL Composite Resource..."
cat <<EOF | kubectl apply -f -
apiVersion: db.example.org/v1alpha1
kind: XPostgreSQLInstance
metadata:
  name: mock-postgresql
spec:
  parameters:
    storageGB: 20
  compositionRef:
    name: mock-postgresql
EOF

echo "Creating mock PostgreSQL Composition..."
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: mock-postgresql
  labels:
    provider: mock
spec:
  compositeTypeRef:
    apiVersion: db.example.org/v1alpha1
    kind: XPostgreSQLInstance
  resources:
  - name: mock-secret
    base:
      apiVersion: v1
      kind: Secret
      metadata:
        name: mock-postgresql-secret
      data:
        username: ZGVtbw==  # demo
        password: ZGVtb3Bhc3N3b3Jk  # demopassword
        endpoint: bG9jYWxob3N0OjU0MzI=  # localhost:5432
    patches:
    - fromFieldPath: metadata.name
      toFieldPath: metadata.name
EOF

echo "✅ Crossplane configured."
echo "⏳ Note: It may take a few minutes for the providers to become healthy."
