#!/bin/bash
set -euo pipefail

echo "🗄️ Setting up PostgreSQL Database for Workshop..."

echo "Creating namespaces..."
kubectl create namespace staging 2>/dev/null || echo "Namespace staging already exists"
kubectl create namespace production 2>/dev/null || echo "Namespace production already exists"

echo "Deploying PostgreSQL database..."
kubectl apply -f ../infra-manifests/database/postgresql.yaml

echo "Creating database connection secrets..."
kubectl apply -f ../infra-manifests/database/secrets.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available deployment/postgresql --timeout=120s

echo "✅ PostgreSQL database setup complete!"
echo "🎯 Now you can demonstrate real self-healing:"
echo "   - Delete the PostgreSQL pod: kubectl delete pod -l app=postgresql"
echo "   - Watch it get recreated automatically"
echo "   - Delete the db-pinger pod: kubectl delete pod -l app=db-pinger -n staging"
echo "   - Watch it get recreated and reconnect to the database"
