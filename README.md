# GitOps and CloudSecOps Workshop

A hands-on workshop for building a secure, multi-environment platform using GitOps principles with ArgoCD, Crossplane, and Vault.

## Overview

This workshop demonstrates how to set up a complete GitOps environment locally using:

- **ArgoCD** - GitOps continuous delivery tool
- **Crossplane** - Cloud-native control plane for infrastructure
- **Kubernetes** - Container orchestration platform
- **Kustomize** - Kubernetes native configuration management

## Prerequisites

Before starting this workshop, ensure you have the following tools installed:

- Docker
- kubectl
- Helm
- kind (Kubernetes in Docker)

## Project Structure

```
gitops-workshop/
├── setup-scripts/                  # Setup automation scripts
│   ├── 01-create-cluster.sh       # Create local Kubernetes cluster
│   ├── 02-install-tools.sh        # Install ArgoCD, Crossplane
│   ├── 03-configure-crossplane.sh # Configure Crossplane providers
│   └── 05-self-healing-demo.sh    # Self-healing demonstration
├── infra-manifests/                # Infrastructure and application manifests
│   ├── crossplane/                 # Crossplane definitions
│   └── apps/
│       └── db-pinger/             # Sample application
│           ├── base/              # Base application configuration
│           └── overlays/          # Environment-specific overlays
│               ├── staging/
│               └── production/
├── argocd-applications.yaml       # ArgoCD application definitions
└── what-we-will-be-doing.html     # Detailed workshop guide
```

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd gitops-workshop
   ```

2. **Run the setup scripts in order:**
   ```bash
   # Create local Kubernetes cluster
   ./setup-scripts/01-create-cluster.sh
   
   # Install platform tools (includes ArgoCD memory fixes)
   ./setup-scripts/02-install-tools.sh
   
   # Configure Crossplane
   ./setup-scripts/03-configure-crossplane.sh
   ```

3. **Optional: If you need to fix ArgoCD memory issues later:**
   ```bash
   ./setup-scripts/02a-fix-argocd-memory.sh
   ```

3. **Apply Crossplane definitions:**
   ```bash
   kubectl apply -f infra-manifests/crossplane/
   ```

4. **Create namespaces:**
   ```bash
   kubectl create ns staging production
   ```

5. **Update ArgoCD applications:**
   - Edit `argocd-applications.yaml` to point to your GitHub repository
   - Apply the applications: `kubectl apply -f argocd-applications.yaml`

6. **Access ArgoCD UI:**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8081:443
   ```
   Open https://localhost:8081 in your browser

## What You'll Learn

- **GitOps Principles**: Declarative infrastructure management
- **Multi-Environment Management**: Staging and production with Kustomize
- **Infrastructure as Code**: Crossplane for cloud resource provisioning
- **Continuous Delivery**: Automated deployments with ArgoCD

## Workshop Guide

For detailed step-by-step instructions, open `what-we-will-be-doing.html` in your browser. This interactive guide includes:

- Complete setup instructions
- Code examples with copy buttons
- Troubleshooting tips
- Best practices

## Architecture

The workshop demonstrates a complete GitOps workflow:

1. **Infrastructure Provisioning**: Crossplane manages cloud resources
2. **Secrets Management**: Vault provides secure secret injection
3. **Application Deployment**: ArgoCD syncs applications from Git
4. **Environment Management**: Kustomize overlays for environment-specific configs
