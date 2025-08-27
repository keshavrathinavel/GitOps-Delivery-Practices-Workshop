#!/bin/bash
set -euo pipefail

echo "🔐 Configuring Vault..."

VAULT_POD="vault-0"

# Wait for Vault to be ready
kubectl wait --for=condition=Ready pod/${VAULT_POD} --timeout=120s

echo "Enabling Kubernetes auth method in Vault..."
kubectl exec ${VAULT_POD} -- vault auth enable kubernetes 2>/dev/null || echo "Kubernetes auth method already enabled"

echo "Configuring Kubernetes auth method..."
kubectl exec ${VAULT_POD} -- vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc" \
    disable_local_ca_jwt="true"

echo "Enabling KV-v2 secrets engine..."
kubectl exec ${VAULT_POD} -- vault secrets enable -path=kv kv-v2 2>/dev/null || echo "KV-v2 secrets engine already enabled"

echo "Creating Vault policy for the app..."
kubectl exec ${VAULT_POD} -- sh -c 'vault policy write db-pinger-policy - <<EOF
path "kv/data/db-pinger/*" {
  capabilities = ["read"]
}
EOF'

echo "Creating Vault role for the app's service account..."
kubectl exec ${VAULT_POD} -- vault write auth/kubernetes/role/db-pinger-role \
    bound_service_account_names=db-pinger-sa \
    bound_service_account_namespaces=staging,production \
    policies=db-pinger-policy \
    ttl=24h

echo "✅ Vault configured successfully."
