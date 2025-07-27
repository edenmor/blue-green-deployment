#!/bin/bash

# Deployment script for blue-green demo
# Usage: ./deploy.sh [build|deploy|all]

set -e

ACTION=${1:-all}

build_images() {
    echo "🔨 Building Docker images..."
    
    echo "Building blue image..."
    cd app/blue
    docker build -t flask-blue:latest .
    cd ../..
    
    echo "Building green image..."
    cd app/green  
    docker build -t flask-green:latest .
    cd ../..
    
    # Load images into Minikube if it's running
    if minikube status &>/dev/null; then
        echo "Loading images into Minikube..."
        minikube image load flask-blue:latest
        minikube image load flask-green:latest
    fi
    
    echo "✅ Images built successfully"
}

deploy_k8s() {
    echo "🚀 Deploying to Kubernetes..."
    
    # Apply all manifests
    kubectl apply -f k8s/blue-deployment.yaml
    kubectl apply -f k8s/green-deployment.yaml
    kubectl apply -f k8s/blue-service.yaml
    kubectl apply -f k8s/green-service.yaml
    kubectl apply -f k8s/ingress.yaml
    
    echo "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/blue-deployment
    kubectl wait --for=condition=available --timeout=300s deployment/green-deployment
    
    echo "✅ Deployment completed successfully"
    
    # Show status
    echo ""
    echo "📊 Deployment Status:"
    kubectl get pods -l app=flask-app
    echo ""
    kubectl get services
    echo ""
    kubectl get ingress
}

case $ACTION in
    build)
        build_images
        ;;
    deploy)
        deploy_k8s
        ;;
    all)
        build_images
        deploy_k8s
        ;;
    *)
        echo "Usage: $0 [build|deploy|all]"
        exit 1
        ;;
esac

echo ""
echo "🎉 Done! You can now test your deployment:"
echo "- ./switch.sh blue   # Switch to blue"
echo "- ./switch.sh green  # Switch to green"
echo "- kubectl port-forward service/blue-service 8080:80"
