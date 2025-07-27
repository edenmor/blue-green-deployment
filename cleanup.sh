#!/bin/bash

# Cleanup script for blue-green demo
# Usage: ./cleanup.sh

set -e

echo "🧹 Cleaning up blue-green deployment demo..."

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete -f k8s/ --ignore-not-found=true

# Wait for pods to terminate
echo "Waiting for pods to terminate..."
kubectl wait --for=delete pods -l app=flask-app --timeout=60s 2>/dev/null || true

# Remove Docker images (optional)
read -p "Do you want to remove Docker images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing Docker images..."
    docker rmi flask-blue:latest flask-green:latest 2>/dev/null || echo "Images already removed or not found"
fi

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "Remaining resources (if any):"
kubectl get all -l app=flask-app 2>/dev/null || echo "No resources found"
