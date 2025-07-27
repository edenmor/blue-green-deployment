#!/bin/bash

# GitOps Blue-Green Switching Script
# This script updates Git files and lets ArgoCD sync automatically

set -e

echo "🔄 GitOps Blue-Green Environment Switching..."

# Check current active environment
CURRENT_ENV=$(grep "activeEnvironment:" k8s-applicationset/ingress/values.yaml | cut -d'"' -f2)

if [[ "$CURRENT_ENV" == "blue" ]]; then
    NEW_ENV="green"
    echo "🔵 Currently active: BLUE → Switching to GREEN"
elif [[ "$CURRENT_ENV" == "green" ]]; then
    NEW_ENV="blue"  
    echo "🟢 Currently active: GREEN → Switching to BLUE"
else
    echo "❌ Could not determine current environment from values.yaml"
    exit 1
fi

echo ""
echo "📝 Updating Git configuration..."

# Update the ingress values.yaml to switch environments
sed -i '' "s/activeEnvironment: \"$CURRENT_ENV\"/activeEnvironment: \"$NEW_ENV\"/" k8s-applicationset/ingress/values.yaml

echo "✅ Updated k8s-applicationset/ingress/values.yaml"
echo "   activeEnvironment: \"$CURRENT_ENV\" → \"$NEW_ENV\""

echo ""
echo "📊 Git Status:"
git diff k8s-applicationset/ingress/values.yaml

echo ""
echo "🚀 Committing GitOps change..."
git add k8s-applicationset/ingress/values.yaml
git commit -m "GitOps: Switch active environment from $CURRENT_ENV to $NEW_ENV

- Update activeEnvironment in ingress/values.yaml
- ArgoCD will automatically sync this change
- Demonstrates proper GitOps blue-green deployment switching"

echo ""
echo "📤 Pushing to GitHub (source of truth)..."
git push origin main

echo ""
echo "⏳ ArgoCD will automatically detect and sync this change..."
echo "📊 Monitor with: kubectl get applications -n argocd"
echo "🌐 Test with: curl -H \"Host: blue-green-demo.local\" http://localhost:8080/"

echo ""
echo "🎉 GitOps switch initiated: $CURRENT_ENV → $NEW_ENV"
echo "✅ Git is the source of truth, ArgoCD handles the deployment!"
