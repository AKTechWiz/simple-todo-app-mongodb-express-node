# Kubernetes Cluster Setup Guide for Jenkins CI/CD Pipeline

## Overview
This guide helps you set up a Kubernetes cluster and configure Jenkins to deploy your application automatically.

## Option 1: AWS EKS (Elastic Kubernetes Service) - RECOMMENDED FOR PRODUCTION

### Step 1: Install Required Tools on Jenkins EC2 Instance

```bash
# SSH into your Jenkins EC2 instance
ssh -i "abd-jenk.pem" ec2-user@13.60.205.183

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

### Step 2: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-north-1
# Default output format: json
```

### Step 3: Create EKS Cluster

```bash
# Create EKS cluster (takes 15-20 minutes)
eksctl create cluster \
  --name devops-todo-cluster \
  --region eu-north-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# Verify cluster
kubectl get nodes
```

### Step 4: Configure Jenkins User

```bash
# Switch to Jenkins user
sudo su - jenkins

# Copy kubeconfig
mkdir -p ~/.kube
cp /root/.kube/config ~/.kube/config
sudo chown jenkins:jenkins ~/.kube/config

# Test kubectl access
kubectl get nodes
```

---

## Option 2: Minikube (Local Development/Testing)

### Step 1: Install Minikube on Jenkins EC2

```bash
# SSH into Jenkins EC2
ssh -i "abd-jenk.pem" ec2-user@13.60.205.183

# Install Docker (if not already installed)
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
sudo minikube start --driver=docker --force

# Configure kubectl for Jenkins user
sudo su - jenkins
mkdir -p ~/.kube
sudo cp -r /root/.minikube ~/.minikube
sudo cp /root/.kube/config ~/.kube/config
sudo chown -R jenkins:jenkins ~/.kube ~/.minikube

# Test
kubectl get nodes
```

---

## Configure Jenkins for Kubernetes Deployment

### Option A: Use System kubeconfig (Simpler)

The Jenkinsfile is already configured to use the system kubeconfig automatically. Just ensure:

1. Jenkins user has access to kubeconfig:
```bash
sudo su - jenkins
kubectl get nodes  # Should work without errors
```

2. If you get permission errors, fix with:
```bash
sudo chown jenkins:jenkins ~/.kube/config
sudo chmod 600 ~/.kube/config
```

### Option B: Use Jenkins Credentials (More Secure)

1. **Get kubeconfig content:**
```bash
sudo cat /var/lib/jenkins/.kube/config
```

2. **Add to Jenkins:**
   - Go to: http://13.60.205.183:8080/manage/credentials/
   - Click: Global credentials → Add Credentials
   - Kind: Secret file
   - File: Upload your kubeconfig or paste content
   - ID: `kubeconfig-credentials`
   - Description: Kubernetes Config

3. **Update Jenkinsfile environment section:**
```groovy
environment {
    KUBECONFIG = credentials('kubeconfig-credentials')
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    DOCKERHUB_USERNAME = 'barzakh'
    IMAGE_NAME = 'todo-app'
    IMAGE_TAG = "${BUILD_NUMBER}"
}
```

---

## Test Kubernetes Access from Jenkins

### Method 1: Pipeline Test Job

Create a test pipeline job in Jenkins with this script:

```groovy
pipeline {
    agent any
    stages {
        stage('Test Kubectl') {
            steps {
                sh '''
                    kubectl version
                    kubectl get nodes
                    kubectl get namespaces
                '''
            }
        }
    }
}
```

### Method 2: Jenkins Script Console

1. Go to: http://13.60.205.183:8080/script/
2. Run this Groovy script:

```groovy
def proc = "kubectl get nodes".execute()
proc.waitFor()
println proc.text
```

---

## Verify Everything Works

```bash
# On Jenkins EC2 instance
sudo su - jenkins

# Test kubectl
kubectl get nodes

# Test namespace
kubectl get namespaces

# Create test pod
kubectl run nginx --image=nginx --restart=Never
kubectl get pods
kubectl delete pod nginx
```

---

## Troubleshooting

### Error: "kubectl: command not found"
```bash
# Add kubectl to Jenkins PATH
sudo ln -s /usr/local/bin/kubectl /usr/bin/kubectl
```

### Error: "The connection to the server localhost:8080 was refused"
```bash
# Kubeconfig not found - copy it
sudo cp -r /root/.kube /var/lib/jenkins/
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

### Error: "error: You must be logged in to the server (Unauthorized)"
```bash
# AWS credentials not configured for EKS
aws configure  # Set AWS credentials
aws eks update-kubeconfig --region eu-north-1 --name devops-todo-cluster
```

### Error: Minikube not accessible
```bash
# Restart Minikube as root then fix permissions
sudo minikube stop
sudo minikube start --driver=docker
sudo cp -r /root/.kube /var/lib/jenkins/
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

---

## Security Considerations

1. **Use Kubernetes RBAC**: Create a service account for Jenkins with limited permissions
2. **Use Jenkins Credentials**: Store kubeconfig securely in Jenkins credentials
3. **Encrypt secrets**: Use Kubernetes secrets for sensitive data
4. **Network policies**: Restrict pod-to-pod communication

---

## Next Steps After Setup

1. ✅ Verify kubectl works: `kubectl get nodes`
2. ✅ Ensure Jenkins user has access
3. ✅ Go to Jenkins: http://13.60.205.183:8080/job/devops-ci-cd-pipeline/
4. ✅ Click "Build Now" to run build #10
5. ✅ Monitor all stages:
   - Code Fetch
   - Build Docker Image
   - Test Docker Image
   - Push to DockerHub
   - **Deploy to Kubernetes** ← NEW
   - **Setup Monitoring** ← NEW
   - **Verify Deployment** ← NEW

---

## Expected Pipeline Output

When successful, you'll see:

```
✓ Code Fetch - Fetched from GitHub
✓ Build Docker Image - Built barzakh/todo-app:10
✓ Test Docker Image - Container tested
✓ Push to DockerHub - Pushed to registry
✓ Deploy to Kubernetes - All pods running
  - mongodb-deployment
  - todo-app-deployment
✓ Setup Monitoring - Prometheus & Grafana deployed
✓ Verify Deployment - All services accessible
```

---

## Access Your Deployed Application

```bash
# Get application URL
kubectl get service todo-app-service

# Get Prometheus URL
kubectl get service prometheus-service

# Get Grafana URL
kubectl get service grafana-service

# If using LoadBalancer
kubectl get svc -o wide
```

For Minikube:
```bash
minikube service todo-app-service --url
minikube service prometheus-service --url
minikube service grafana-service --url
```

---

## Marks Breakdown (Total: 50)

- ✅ Code Fetch Stage: **6 marks**
- ✅ Docker Image Creation: **10 marks**
- ⏳ Kubernetes Deployment: **17 marks** ← Need to run build #10
- ⏳ Prometheus/Grafana: **17 marks** ← Need to run build #10

**Current Status: 16/50 marks (32%)**  
**After K8s setup: 50/50 marks (100%)**
