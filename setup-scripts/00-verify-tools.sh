#!/bin/bash

echo "Checking workshop prerequisites..."
docker --version && echo "✅ Docker OK" || echo "❌ Docker missing"
kubectl version --client && echo "✅ kubectl OK" || echo "❌ kubectl missing"
helm version && echo "✅ Helm OK" || echo "❌ Helm missing"
kind version && echo "✅ kind OK" || echo "❌ kind missing"