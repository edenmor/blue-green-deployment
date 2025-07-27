#!/bin/bash

# ArgoCD Blue-Green Deployment Switch Script
# Usage: ./argocd-switch.sh [blue|green]

set -e

ENVIRONMENT=$1
NAMESPACE=${2:-flask-app}

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

echo "Switching to $ENVIRONMENT environment in namespace $NAMESPACE..."

# Set the appropriate port based on environment
if [ "$ENVIRONMENT" = "blue" ]; then
    PORT=8080
else
    PORT=80
fi

# Patch the ingress directly
kubectl patch ingress flask-app-ingress -n $NAMESPACE --type='json' \
  -p="[{'op': 'replace', 'path': '/spec/rules/0/http/paths/0/backend/service/name', 'value': '${ENVIRONMENT}-service'}, {'op': 'replace', 'path': '/spec/rules/0/http/paths/0/backend/service/port/number', 'value': ${PORT}}]"

echo "✅ Successfully switched to $ENVIRONMENT environment"

# Verify the switch
echo "Verifying the switch..."
CURRENT_SERVICE=$(kubectl get ingress flask-app-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
echo "Current service: $CURRENT_SERVICE"

echo "🎉 Blue-Green deployment switch completed!"
echo ""
echo "You can test the deployment using:"
echo "- kubectl port-forward service/${ENVIRONMENT}-service 8080:${PORT} -n $NAMESPACE"
echo "- curl http://localhost:8080"
