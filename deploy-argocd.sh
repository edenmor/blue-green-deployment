#!/bin/bash

# ArgoCD App of Apps Deployment Script
# Make sure to update the GitHub repo URL in the YAML files before running

set -e

echo "🚀 Deploying Blue-Green Flask App via ArgoCD App of Apps pattern..."

# Check if ArgoCD is running
if ! kubectl get pods -n argocd &>/dev/null; then
    echo "❌ ArgoCD is not found in the argocd namespace"
    echo "Please install ArgoCD first:"
    echo "kubectl create namespace argocd"
    echo "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

echo "✅ ArgoCD found, proceeding with deployment..."

# Apply the App of Apps
echo "📦 Creating App of Apps..."
kubectl apply -f argocd-apps/app-of-apps.yaml

echo "⏳ Waiting for App of Apps to sync..."
sleep 5

# Check the applications
echo "📊 ArgoCD Applications:"
kubectl get applications -n argocd

echo ""
echo "🎉 App of Apps deployment initiated!"
echo ""
echo "Next steps:"
echo "1. Update the GitHub repo URLs in argocd-apps/*.yaml files"
echo "2. Push your code to GitHub"
echo "3. Access ArgoCD UI to monitor the deployment"
echo ""
echo "To access ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Username: admin"
echo "Password: \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
