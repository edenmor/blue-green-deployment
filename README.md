# Blue-Green Deployment Demo with Flask and Kubernetes

This project demonstrates blue-green deployment patterns using Flask applications deployed on Kubernetes. It's designed to work with Minikube for local development and testing.

## Project Structure

```
green-blue-demo/
├── app/
│   ├── blue/
│   │   ├── app.py              # Blue version Flask app
│   │   └── Dockerfile          # Blue version container
│   └── green/
│       ├── app.py              # Green version Flask app
│       └── Dockerfile          # Green version container
├── k8s/
│   ├── blue-deployment.yaml    # Blue deployment manifest
│   ├── green-deployment.yaml   # Green deployment manifest
│   ├── blue-service.yaml       # Blue service manifest
│   ├── green-service.yaml      # Green service manifest
│   └── ingress.yaml            # Ingress for traffic routing
├── switch.sh                   # Blue-green deployment switch script
└── README.md                   # This file
```

## Features

- **Two environments**: Blue (v1.0.0) and Green (v2.0.0) Flask applications
- **Health checks**: Both applications expose `/health` endpoints
- **Container health checks**: Dockerfiles include health check configurations
- **Kubernetes manifests**: Complete deployment, service, and ingress configurations
- **NodePort services**: Direct access to each environment for testing
- **Ingress routing**: Smart routing with hostname-based and switchable routing
- **Automated switching**: Script to switch between blue and green deployments

## Prerequisites

- Docker
- Kubernetes cluster (Minikube recommended for local development)
- kubectl configured to communicate with your cluster
- curl (for testing)

## Quick Start

### 1. Start Minikube (if using local development)

```bash
minikube start
minikube addons enable ingress
```

### 2. Build Docker Images

Build the blue version:
```bash
cd app/blue
docker build -t flask-blue:latest .
```

Build the green version:
```bash
cd ../green
docker build -t flask-green:latest .
```

If using Minikube, load images into Minikube:
```bash
minikube image load flask-blue:latest
minikube image load flask-green:latest
```

### 3. Deploy to Kubernetes

Deploy both environments:
```bash
kubectl apply -f k8s/blue-deployment.yaml
kubectl apply -f k8s/green-deployment.yaml
kubectl apply -f k8s/blue-service.yaml
kubectl apply -f k8s/green-service.yaml
kubectl apply -f k8s/ingress.yaml
```

### 4. Test the Deployments

**Option A: Using NodePort (Direct Access)**
```bash
# Test blue environment
kubectl port-forward service/blue-service 8080:80
curl http://localhost:8080

# Test green environment (in another terminal)
kubectl port-forward service/green-service 8081:80
curl http://localhost:8081
```

**Option B: Using Ingress**
```bash
# Add to /etc/hosts (replace with your Minikube IP)
echo "$(minikube ip) flask-app.local blue.flask-app.local green.flask-app.local" | sudo tee -a /etc/hosts

# Test main endpoint (defaults to blue)
curl http://flask-app.local

# Test specific environments
curl http://blue.flask-app.local
curl http://green.flask-app.local
```

## Blue-Green Deployment

### Switch Between Environments

Use the provided script to switch the main traffic between blue and green:

```bash
# Switch to green environment
./switch.sh green

# Switch to blue environment  
./switch.sh blue

# Check current active environment
./switch.sh
```

### Manual Switching

You can also manually patch the ingress:

```bash
# Switch to green
kubectl patch ingress flask-app-ingress --type='json' \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value": "green-service"}]'

# Switch to blue
kubectl patch ingress flask-app-ingress --type='json' \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value": "blue-service"}]'
```

## API Endpoints

Each application exposes the following endpoints:

- `/` - Main endpoint showing environment info
- `/health` - Health check endpoint
- `/info` - Detailed environment information

### Example Responses

**Blue Environment Response:**
```json
{
  "environment": "Blue",
  "message": "Blue environment is active!",
  "hostname": "blue-deployment-xxx-yyy",
  "version": "1.0.0"
}
```

**Green Environment Response:**
```json
{
  "environment": "Green", 
  "message": "Green environment is active!",
  "hostname": "green-deployment-xxx-yyy",
  "version": "2.0.0"
}
```

## Monitoring and Health Checks

### Check Pod Status
```bash
kubectl get pods -l app=flask-app
```

### Check Service Status
```bash
kubectl get services
```

### Check Ingress Status
```bash
kubectl get ingress
```

### View Logs
```bash
# Blue environment logs
kubectl logs -l version=blue

# Green environment logs  
kubectl logs -l version=green
```

## Advanced Usage

### Rolling Updates

Update the blue deployment:
```bash
# Build new image
docker build -t flask-blue:v1.1.0 app/blue/

# Update deployment
kubectl set image deployment/blue-deployment flask-app=flask-blue:v1.1.0
```

### Scaling

Scale individual environments:
```bash
# Scale blue environment
kubectl scale deployment blue-deployment --replicas=5

# Scale green environment
kubectl scale deployment green-deployment --replicas=2
```

### Canary Deployments

You can implement canary deployments by:
1. Deploying the new version (green) alongside the current version (blue)
2. Gradually shifting traffic using ingress weights or service mesh
3. Monitoring metrics and rolling back if needed

## Cleanup

Remove all resources:
```bash
kubectl delete -f k8s/
```

Remove Docker images:
```bash
docker rmi flask-blue:latest flask-green:latest
```

## Best Practices Implemented

- **Health checks**: Kubernetes liveness and readiness probes
- **Resource limits**: CPU and memory limits defined
- **Labels and selectors**: Proper labeling for organization
- **Environment variables**: Configuration through env vars
- **Zero-downtime deployments**: Blue-green switching without service interruption
- **Monitoring endpoints**: Health and info endpoints for observability

## Troubleshooting

### Common Issues

1. **Images not found**: Make sure to load images into Minikube with `minikube image load`
2. **Ingress not working**: Ensure ingress addon is enabled with `minikube addons enable ingress`
3. **DNS resolution**: Add entries to `/etc/hosts` for local testing
4. **Service not accessible**: Check if services are running with `kubectl get svc`

### Debugging Commands

```bash
# Check pod status and events
kubectl describe pod <pod-name>

# Check service endpoints
kubectl get endpoints

# Check ingress configuration
kubectl describe ingress flask-app-ingress

# Port forward for direct access
kubectl port-forward deployment/blue-deployment 8080:5000
```

## Next Steps

- Implement automated health checks during deployment
- Add monitoring with Prometheus and Grafana
- Implement automatic rollback on health check failures
- Add CI/CD pipeline for automated deployments
- Integrate with service mesh (Istio) for advanced traffic management

## Contributing

Feel free to submit issues and enhancement requests!
