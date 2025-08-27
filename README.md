# (Short) GitOps Workshop

A short hands-on workshop for building a multi-environment platform using GitOps principles with ArgoCD and Kubernetes.

## Overview

This workshop demonstrates how to set up a complete GitOps environment locally using:

- **ArgoCD** - GitOps continuous delivery tool
- **Kubernetes** - Container orchestration platform
- **Kustomize** - Kubernetes native configuration management
- **PostgreSQL** - Database for self-healing demonstrations

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
│   ├── 02-install-tools.sh        # Install ArgoCD
│   ├── 03-setup-database.sh       # Setup PostgreSQL database
│   └── 05-self-healing-demo.sh    # Self-healing demonstration
├── infra-manifests/                # Infrastructure and application manifests
│   ├── database/                   # Database manifests
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
   
   # Setup Database
   ./setup-scripts/03-setup-database.sh
   ```

3. **Optional: If you need to fix ArgoCD memory issues later:**
   ```bash
   ./setup-scripts/02a-fix-argocd-memory.sh
   ```

3. **Create namespaces:**
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
- **Self-Healing Infrastructure**: Real database connectivity and recovery
- **Continuous Delivery**: Automated deployments with ArgoCD

## Workshop Guide

For detailed step-by-step instructions, open `what-we-will-be-doing.html` in your browser. This interactive guide includes:

- Complete setup instructions
- Code examples with copy buttons
- Troubleshooting tips

## Architecture

The workshop demonstrates a complete GitOps workflow:

1. **Application Deployment**: ArgoCD syncs applications from Git
2. **Environment Management**: Kustomize overlays for environment-specific configs
