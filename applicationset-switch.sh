#!/bin/bash

# ApplicationSet Blue-Green Switching Script
# This script demonstrates how to switch between blue and green in ApplicationSet pattern

set -e

echo "🔄 ApplicationSet Blue-Green Switching..."

# Check current active environment by looking at applications
BLUE_APP_EXISTS=$(kubectl get application flask-blue-app -n argocd -o jsonpath='{.metadata.name}' 2>/dev/null || echo "")
GREEN_APP_EXISTS=$(kubectl get application flask-green-app -n argocd -o jsonpath='{.metadata.name}' 2>/dev/null || echo "")

if [[ -z "$BLUE_APP_EXISTS" || -z "$GREEN_APP_EXISTS" ]]; then
    echo "❌ ApplicationSet applications not found. Please deploy first using ./deploy-applicationset.sh"
    exit 1
fi

echo "📊 Current ApplicationSet Applications:"
kubectl get applications -n argocd -l environment

echo ""
echo "🔍 Checking current service configuration..."
CURRENT_INGRESS_SERVICE=$(kubectl get ingress flask-app-ingress -n flask-app -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null || echo "not-found")

if [[ "$CURRENT_INGRESS_SERVICE" == "blue-service" ]]; then
    CURRENT_ENV="blue"
    NEW_ENV="green"
    NEW_SERVICE="green-service"
    echo "🔵 Currently serving: BLUE environment"
elif [[ "$CURRENT_INGRESS_SERVICE" == "green-service" ]]; then
    CURRENT_ENV="green"
    NEW_ENV="blue"
    NEW_SERVICE="blue-service"
    echo "🟢 Currently serving: GREEN environment"
else
    echo "❌ Could not determine current environment. Ingress service: $CURRENT_INGRESS_SERVICE"
    echo "Available services:"
    kubectl get services -n flask-app
    exit 1
fi

echo ""
echo "🔄 Switching from $CURRENT_ENV to $NEW_ENV..."

# Create or update ingress to point to new service
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-app-ingress
  namespace: flask-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: blue-green-demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $NEW_SERVICE
            port:
              number: 80
EOF

echo "✅ Switched ingress to $NEW_ENV environment ($NEW_SERVICE)"

echo ""
echo "🌐 Testing the switch..."
sleep 3

# Test the new environment
if command -v curl &> /dev/null; then
    echo "Making test request to ingress..."
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "127.0.0.1")
    curl -H "Host: blue-green-demo.local" http://$MINIKUBE_IP/ 2>/dev/null || echo "Direct curl failed, try port-forward"
else
    echo "curl not available, skipping HTTP test"
fi

echo ""
echo "🎉 Blue-Green switch completed!"
echo ""
echo "📊 ApplicationSet Benefits Demonstrated:"
echo "✅ Both environments managed by single ApplicationSet"
echo "✅ Parameterized configurations (different ports, versions)"
echo "✅ Easy scaling: Add more environments by updating the generator"
echo "✅ GitOps: Changes to ApplicationSet automatically propagate"
echo ""
echo "🔧 Current Configuration:"
echo "- Active Environment: $NEW_ENV"
echo "- Service: $NEW_SERVICE"
echo "- Previous Environment: $CURRENT_ENV (still running)"
echo ""
echo "To verify the switch:"
echo "kubectl get ingress flask-app-ingress -n flask-app -o yaml"
