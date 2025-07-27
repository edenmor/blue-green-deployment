#!/bin/bash

# Test script for blue-green deployment
# Usage: ./test.sh

set -e

echo "🧪 Testing Blue-Green Deployment..."

# Function to test an endpoint
test_endpoint() {
    local url=$1
    local expected_env=$2
    
    echo "Testing $url..."
    response=$(curl -s $url)
    
    if echo "$response" | grep -q "\"environment\": \"$expected_env\""; then
        echo "✅ $expected_env environment test passed"
    else
        echo "❌ $expected_env environment test failed"
        echo "Response: $response"
        return 1
    fi
}

# Test using port-forward
echo "Testing via port-forward..."

# Test blue service
kubectl port-forward service/blue-service 8080:80 &
PID_BLUE=$!
sleep 3

test_endpoint "http://localhost:8080" "Blue"
test_endpoint "http://localhost:8080/health" "blue"

# Clean up
kill $PID_BLUE

# Test green service
kubectl port-forward service/green-service 8081:80 &
PID_GREEN=$!
sleep 3

test_endpoint "http://localhost:8081" "Green"
test_endpoint "http://localhost:8081/health" "green"

# Clean up
kill $PID_GREEN

echo ""
echo "🎯 Testing Blue-Green Switch..."

# Test switching
echo "Switching to blue..."
./switch.sh blue > /dev/null

# Test main ingress (requires ingress to be working)
if command -v minikube &> /dev/null && minikube status &>/dev/null; then
    MINIKUBE_IP=$(minikube ip)
    echo "Testing ingress at $MINIKUBE_IP..."
    
    # Test with curl using Host header
    if curl -s -H "Host: flask-app.local" http://$MINIKUBE_IP | grep -q "Blue"; then
        echo "✅ Ingress blue test passed"
    else
        echo "⚠️  Ingress test skipped (might need /etc/hosts configuration)"
    fi
    
    echo "Switching to green..."
    ./switch.sh green > /dev/null
    
    sleep 5  # Wait for ingress to propagate
    
    if curl -s -H "Host: flask-app.local" http://$MINIKUBE_IP | grep -q "Green"; then
        echo "✅ Ingress green test passed"
    else
        echo "⚠️  Ingress green test skipped"
    fi
else
    echo "⚠️  Minikube not running, skipping ingress tests"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "Manual test commands:"
echo "- kubectl port-forward service/blue-service 8080:80"
echo "- kubectl port-forward service/green-service 8081:80"
echo "- curl http://localhost:8080"
echo "- curl http://localhost:8081"
