#!/bin/bash

# Blue-Green Deployment Switch Script
# Usage: ./switch.sh [blue|green]

set -e

ENVIRONMENT=$1
NAMESPACE=${2:-default}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 [blue|green] [namespace]"
    echo "Current active environment:"
    kubectl get ingress flask-app-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' | sed 's/-service//'
    exit 1
fi

if [ "$ENVIRONMENT" != "blue" ] && [ "$ENVIRONMENT" != "green" ]; then
    echo "Error: Environment must be 'blue' or 'green'"
    exit 1
fi

echo "Switching to $ENVIRONMENT environment..."

# Set the appropriate port based on environment
if [ "$ENVIRONMENT" = "blue" ]; then
    PORT=8080
else
    PORT=80
fi

# Method 1: Patch the ingress directly
kubectl patch ingress flask-app-ingress -n $NAMESPACE --type='json' \
  -p="[{'op': 'replace', 'path': '/spec/rules/0/http/paths/0/backend/service/name', 'value': '${ENVIRONMENT}-service'}, {'op': 'replace', 'path': '/spec/rules/0/http/paths/0/backend/service/port/number', 'value': ${PORT}}]"

echo "✅ Successfully switched to $ENVIRONMENT environment"

# Verify the switch
echo "Verifying the switch..."
CURRENT_SERVICE=$(kubectl get ingress flask-app-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
echo "Current service: $CURRENT_SERVICE"

# Wait for ingress to propagate
echo "Waiting for ingress to propagate (30 seconds)..."
sleep 30

echo "🎉 Blue-Green deployment switch completed!"
echo ""
echo "You can test the deployment using:"
echo "- kubectl port-forward service/${ENVIRONMENT}-service 8080:80 -n $NAMESPACE"
echo "- curl http://localhost:8080"
echo ""
echo "Or if using Minikube with ingress:"
echo "- minikube addons enable ingress"
echo "- Add '$(minikube ip) flask-app.local' to your /etc/hosts"
echo "- curl http://flask-app.local"
