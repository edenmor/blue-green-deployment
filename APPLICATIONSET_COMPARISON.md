# ApplicationSet vs App of Apps Comparison

## Overview

This project demonstrates two ArgoCD patterns for managing blue-green deployments:

## 🔄 App of Apps Pattern (Traditional)

### Files:
- `argocd-apps/app-of-apps.yaml` - Parent application
- `argocd-apps/flask-app.yaml` - Child application  
- `deploy-argocd.sh` - Deployment script
- `argocd-switch.sh` - Switching script

### Characteristics:
- ✅ **Simple**: Easy to understand parent-child relationship
- ✅ **Static**: Predictable, known applications
- ❌ **Manual**: Each application needs its own YAML file
- ❌ **Repetitive**: Similar configs for each environment
- ❌ **Limited templating**: Hard-coded values

### Use Cases:
- Small number of applications
- Different applications with unique configurations
- Teams new to ArgoCD
- When you need fine-grained control over each app

## 🚀 ApplicationSet Pattern (Modern)

### Files:
- `argocd-apps/applicationset-blue-green.yaml` - ApplicationSet definition
- `k8s-applicationset/blue/` - Helm chart for blue
- `k8s-applicationset/green/` - Helm chart for green  
- `deploy-applicationset.sh` - Deployment script
- `applicationset-switch.sh` - Switching script

### Characteristics:
- ✅ **Dynamic**: Generates applications automatically
- ✅ **Templating**: Uses generators and Helm for flexibility
- ✅ **DRY**: One template for multiple environments
- ✅ **Scalable**: Easy to add more environments
- ✅ **Parameterized**: Different values per environment

### Use Cases:
- Multiple similar environments (dev/staging/prod)
- Blue-green deployments
- Multi-tenant applications
- When you need to scale to many environments

## 🔍 Key Differences

| Feature | App of Apps | ApplicationSet |
|---------|-------------|----------------|
| **Setup Complexity** | Simple | Moderate |
| **Scalability** | Limited | Excellent |
| **Templating** | None | Advanced |
| **Maintenance** | High (manual) | Low (automated) |
| **Learning Curve** | Easy | Moderate |
| **Use Case** | Few static apps | Many similar apps |

## 🎯 ApplicationSet Generators

The ApplicationSet uses a **List Generator** to create blue and green environments:

```yaml
generators:
- list:
    elements:
    - environment: blue
      version: "1.0.0"
      port: "8080"
      active: "true"
    - environment: green
      version: "2.0.0" 
      port: "80"
      active: "false"
```

Other available generators:
- **Git Generator**: Generate apps from Git repo structure
- **Cluster Generator**: Generate apps for multiple clusters
- **SCM Provider**: Generate from GitHub/GitLab organizations
- **Matrix Generator**: Combine multiple generators

## 🚀 Getting Started

### Try App of Apps:
```bash
./deploy-argocd.sh
./argocd-switch.sh
```

### Try ApplicationSet:
```bash  
./deploy-applicationset.sh
./applicationset-switch.sh
```

## 🔄 Blue-Green Switching

Both patterns support blue-green deployments, but ApplicationSet provides:
- **Parameterized environments**: Different ports, versions, replicas
- **Unified management**: Single ApplicationSet manages both
- **Easy expansion**: Add staging, development environments easily
- **GitOps friendly**: Changes to generator automatically create/update apps

## 🏆 Recommendation

- **Use App of Apps** when you have a small number of distinct applications
- **Use ApplicationSet** when you have multiple similar environments or need blue-green deployments

For blue-green deployments, **ApplicationSet is the recommended approach** due to its templating and scaling capabilities.
