#!/bin/bash
# Comprehensive test script for IoT Bonus requirements
# Run this after GitLab project setup is complete

echo "🧪 IoT Bonus - Requirements Testing"
echo "=================================="

# Test 1: GitLab instance running locally
echo "[1/8] Testing GitLab local instance..."
if curl -s -o /dev/null -w "%{http_code}" http://192.168.56.111.nip.io:8080 | grep -q "200\|302"; then
    echo "✅ GitLab is accessible locally"
else
    echo "❌ GitLab not accessible"
fi

# Test 2: Required namespaces exist
echo "[2/8] Testing required namespaces..."
NAMESPACES=$(kubectl get namespaces -o name)
if echo "$NAMESPACES" | grep -q "namespace/gitlab" && \
   echo "$NAMESPACES" | grep -q "namespace/argocd" && \
   echo "$NAMESPACES" | grep -q "namespace/dev"; then
    echo "✅ All required namespaces exist: gitlab, argocd, dev"
else
    echo "❌ Missing required namespaces"
    echo "Found namespaces:"
    kubectl get namespaces
fi

# Test 3: GitLab configured for cluster
echo "[3/8] Testing GitLab cluster integration..."
GITLAB_PODS=$(kubectl get pods -n gitlab -l app=webservice --no-headers 2>/dev/null | wc -l)
if [ "$GITLAB_PODS" -gt 0 ]; then
    echo "✅ GitLab is running in cluster ($GITLAB_PODS webservice pods)"
else
    echo "❌ GitLab not properly deployed in cluster"
fi

# Test 4: ArgoCD running
echo "[4/8] Testing ArgoCD deployment..."
if kubectl get deployment argocd-server -n argocd > /dev/null 2>&1; then
    ARGOCD_STATUS=$(kubectl get deployment argocd-server -n argocd -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [ "$ARGOCD_STATUS" -gt 0 ]; then
        echo "✅ ArgoCD server is running"
    else
        echo "⏳ ArgoCD server not ready yet"
    fi
else
    echo "❌ ArgoCD not deployed"
fi

# Test 5: Part 3 functionality (ArgoCD application)
echo "[5/8] Testing ArgoCD application (Part 3 functionality)..."
if kubectl get application wil-app -n argocd > /dev/null 2>&1; then
    APP_STATUS=$(kubectl get application wil-app -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
    APP_HEALTH=$(kubectl get application wil-app -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")
    echo "✅ ArgoCD Application 'wil-app' exists"
    echo "   Sync Status: $APP_STATUS"
    echo "   Health Status: $APP_HEALTH"
else
    echo "⏳ ArgoCD Application not found (create it after GitLab project setup)"
fi

# Test 6: Application deployment in dev namespace
echo "[6/8] Testing application in dev namespace..."
APP_PODS=$(kubectl get pods -n dev -l app=wil-playground --no-headers 2>/dev/null | wc -l)
if [ "$APP_PODS" -gt 0 ]; then
    echo "✅ Application pods running in dev namespace: $APP_PODS"
    kubectl get pods -n dev -l app=wil-playground
else
    echo "⏳ No application pods found (will appear after GitLab→ArgoCD sync)"
fi

# Test 7: Application accessibility
echo "[7/8] Testing application accessibility..."
if curl -s -m 5 http://192.168.56.111:30888/ > /dev/null 2>&1; then
    RESPONSE=$(curl -s -m 5 http://192.168.56.111:30888/)
    echo "✅ Application is accessible"
    echo "   Response: $RESPONSE"
    
    # Check if it's v1 or v2
    if echo "$RESPONSE" | grep -q "v1"; then
        echo "   Current version: v1"
    elif echo "$RESPONSE" | grep -q "v2"; then
        echo "   Current version: v2"
    fi
else
    echo "⏳ Application not accessible yet (normal if not deployed)"
fi

# Test 8: GitLab CI/CD runner
echo "[8/8] Testing GitLab CI/CD integration..."
RUNNER_PODS=$(kubectl get pods -n gitlab -l app=gitlab-runner --no-headers 2>/dev/null | wc -l)
if [ "$RUNNER_PODS" -gt 0 ]; then
    echo "✅ GitLab Runner is deployed: $RUNNER_PODS pods"
else
    echo "⏳ GitLab Runner not found"
fi

echo ""
echo "=================================="
echo "🎯 TESTING SUMMARY"
echo "=================================="

# Overall assessment
echo "🔗 ACCESS URLS:"
echo "   GitLab:  http://192.168.56.111.nip.io:8080"
echo "   ArgoCD:  http://192.168.56.111:31080"
echo "   App:     http://192.168.56.111:30888"

echo ""
echo "📋 MANUAL TESTS REQUIRED:"
echo "   1. ✅ Access GitLab web interface"
echo "   2. ✅ Create 'wil-app' project (public)"
echo "   3. ✅ Upload application manifests to GitLab"
echo "   4. ✅ Apply ArgoCD application config"
echo "   5. ✅ Verify ArgoCD syncs from GitLab"
echo "   6. ✅ Test CI/CD pipeline (v1 ↔ v2 switch)"
echo "   7. ✅ Confirm auto-sync works"

echo ""
echo "🔑 Get credentials with: make passwords"
echo "📖 Get setup guide with: make configure"
echo "=================================="