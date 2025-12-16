#!/bin/bash
###############################################################################
# COMPLETE KUBERNETES DEPLOYMENT SCRIPT
# Project: DevOps CI/CD Pipeline with Jenkins, Docker, Kubernetes
# Course: CSC418 - DevOps for Cloud Computing
# Due: December 16, 2025
###############################################################################

set -e  # Exit on any error

echo "=========================================="
echo "  Starting Complete Kubernetes Setup"
echo "=========================================="

# Step 1: Clean up any existing Kubernetes installation
echo ""
echo "[1/10] Cleaning up old Kubernetes installations..."
sudo rm -rf /root/.minikube /root/.kube /var/lib/minikube /etc/kubernetes 2>/dev/null || true
sudo pkill -9 kubectl 2>/dev/null || true
sudo pkill -9 minikube 2>/dev/null || true
echo "✓ Cleanup complete"

# Step 2: Verify kubectl and minikube are installed
echo ""
echo "[2/10] Verifying kubectl installation..."
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi
kubectl version --client
echo "✓ kubectl ready"

echo ""
echo "[3/10] Verifying minikube installation..."
if ! command -v minikube &> /dev/null; then
    echo "Installing minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
fi
minikube version
echo "✓ minikube ready"

# Step 3: Start Minikube cluster
echo ""
echo "[4/10] Starting Minikube cluster (this takes 2-3 minutes)..."
sudo minikube start --driver=docker --force --memory=4096 --cpus=2
echo "✓ Minikube started"

# Step 4: Verify cluster
echo ""
echo "[5/10] Verifying Kubernetes cluster..."
sudo kubectl get nodes
echo "✓ Cluster verified"

# Step 5: Navigate to application directory
echo ""
echo "[6/10] Navigating to application directory..."
cd /var/lib/jenkins/workspace/devops-ci-cd-pipeline
echo "Current directory: $(pwd)"
echo "✓ Directory ready"

# Step 6: Deploy application to Kubernetes
echo ""
echo "[7/10] Deploying application to Kubernetes..."

echo "  → Creating PersistentVolumeClaim..."
sudo kubectl apply -f k8s/pvc.yaml

echo "  → Deploying MongoDB..."
sudo kubectl apply -f k8s/mongodb-deployment.yaml
sudo kubectl apply -f k8s/mongodb-service.yaml

echo "  → Deploying Todo Application..."
sudo kubectl apply -f k8s/deployment.yaml
sudo kubectl apply -f k8s/service.yaml

echo "✓ Application deployed"

# Step 7: Deploy monitoring stack
echo ""
echo "[8/10] Deploying Prometheus and Grafana..."

echo "  → Deploying Prometheus..."
sudo kubectl apply -f k8s/prometheus-config.yaml
sudo kubectl apply -f k8s/prometheus-deployment.yaml
sudo kubectl apply -f k8s/prometheus-service.yaml

echo "  → Deploying Grafana..."
sudo kubectl apply -f k8s/grafana-deployment.yaml
sudo kubectl apply -f k8s/grafana-service.yaml

echo "✓ Monitoring deployed"

# Step 8: Wait for all pods to be ready
echo ""
echo "[9/10] Waiting for all pods to be ready (this may take 2-3 minutes)..."
echo "Waiting for MongoDB..."
sudo kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s

echo "Waiting for Todo App..."
sudo kubectl wait --for=condition=ready pod -l app=todo-app --timeout=300s

echo "Waiting for Prometheus..."
sudo kubectl wait --for=condition=ready pod -l app=prometheus --timeout=300s

echo "Waiting for Grafana..."
sudo kubectl wait --for=condition=ready pod -l app=grafana --timeout=300s

echo "✓ All pods are ready"

# Step 9: Display deployment status
echo ""
echo "[10/10] Deployment Status"
echo "=========================================="

echo ""
echo "📦 PODS:"
sudo kubectl get pods -o wide

echo ""
echo "🌐 SERVICES:"
sudo kubectl get services

echo ""
echo "💾 PERSISTENT VOLUME CLAIMS:"
sudo kubectl get pvc

echo ""
echo "🚀 DEPLOYMENTS:"
sudo kubectl get deployments

echo ""
echo "=========================================="
echo "  ✅ DEPLOYMENT COMPLETE!"
echo "=========================================="

# Step 10: Get service URLs
echo ""
echo "📍 APPLICATION URLs:"
echo ""

TODO_URL=$(sudo minikube service todo-app-service --url 2>/dev/null || echo "Pending...")
PROMETHEUS_URL=$(sudo minikube service prometheus-service --url 2>/dev/null || echo "Pending...")
GRAFANA_URL=$(sudo minikube service grafana-service --url 2>/dev/null || echo "Pending...")

echo "Todo Application:  $TODO_URL"
echo "Prometheus:        $PROMETHEUS_URL"
echo "Grafana:           $GRAFANA_URL"
echo ""
echo "Grafana Credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""

# Configure Jenkins user access
echo ""
echo "🔧 Configuring Jenkins user access..."
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp -r /root/.kube/config /var/lib/jenkins/.kube/config
sudo cp -r /root/.minikube /var/lib/jenkins/.minikube
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
sudo usermod -aG docker jenkins

echo "✓ Jenkins configured"

# Test Jenkins user access
echo ""
echo "Testing kubectl access for Jenkins user..."
sudo -u jenkins kubectl get nodes
echo "✓ Jenkins user can access Kubernetes"

echo ""
echo "=========================================="
echo "  🎉 PROJECT DEPLOYMENT SUCCESSFUL!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Access the URLs above in your browser"
echo "2. Take screenshots of:"
echo "   - Jenkins Build #9 SUCCESS page"
echo "   - DockerHub repository (hub.docker.com/r/barzakh/todo-app)"
echo "   - kubectl get pods output (shown above)"
echo "   - kubectl get services output (shown above)"
echo "   - Todo application in browser"
echo "   - Prometheus dashboard in browser"
echo "   - Grafana dashboard in browser"
echo "3. Go to Jenkins and run Build #11"
echo "4. Compile your report with all screenshots"
echo ""
echo "=========================================="
echo "  Total Time Elapsed: $SECONDS seconds"
echo "=========================================="
