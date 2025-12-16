# DevOps CI/CD Pipeline Project
## Simple Todo Application with Jenkins, Docker, Kubernetes, Prometheus & Grafana

**Course:** CSC418 – DevOps for Cloud Computing  
**Institution:** COMSATS University, Islamabad  
**Submission Date:** 16-12-25

---

## Project Overview

This project implements a complete CI/CD pipeline for a Node.js Todo application using Jenkins, Docker, Kubernetes, Prometheus, and Grafana. The pipeline automates the entire software delivery process from code fetch to deployment and monitoring.

### Application Details
- **Application Type:** Todo Application
- **Backend:** Node.js with Express.js
- **Database:** MongoDB
- **Frontend:** Handlebars templates
- **Authentication:** Passport.js with bcrypt

---

## Architecture

```
GitHub Repository
      ↓
Jenkins Pipeline
      ↓
Docker Image Build
      ↓
DockerHub Registry
      ↓
Kubernetes Cluster
      ↓
Prometheus & Grafana Monitoring
```

---

## Project Structure

```
simple-todo-app-mongodb-express-node/
├── app.js                          # Main application file
├── package.json                    # Node.js dependencies
├── Dockerfile                      # Docker image configuration
├── .dockerignore                   # Docker build exclusions
├── Jenkinsfile                     # Jenkins CI/CD pipeline script
├── config/
│   ├── database.js                 # MongoDB configuration
│   └── passport.js                 # Authentication configuration
├── models/                         # Mongoose data models
├── routes/                         # Express routes
├── views/                          # Handlebars templates
├── public/                         # Static assets
└── k8s/                           # Kubernetes configurations
    ├── pvc.yaml                    # PersistentVolumeClaim for MongoDB
    ├── mongodb-deployment.yaml     # MongoDB deployment
    ├── mongodb-service.yaml        # MongoDB service
    ├── deployment.yaml             # Todo app deployment
    ├── service.yaml                # Todo app service
    ├── prometheus-config.yaml      # Prometheus configuration
    ├── prometheus-deployment.yaml  # Prometheus deployment
    ├── prometheus-service.yaml     # Prometheus service
    ├── grafana-deployment.yaml     # Grafana deployment
    └── grafana-service.yaml        # Grafana service
```

---

## Prerequisites

### Required Software
1. **Jenkins** (installed on AWS EC2 instance)
2. **Docker** (with Docker Pipeline plugin)
3. **Kubernetes Cluster** (kubectl configured)
4. **Git** (for version control)
5. **DockerHub Account** (for image registry)

### Jenkins Plugins Required
- Git Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- Kubernetes Plugin
- GitHub Webhook Plugin

---

## Setup Instructions

### 1. AWS EC2 Setup for Jenkins

#### Launch EC2 Instance
```bash
# Instance Type: t2.medium or larger
# OS: Ubuntu 20.04 LTS
# Security Group: Allow ports 8080 (Jenkins), 22 (SSH)
```

#### Install Jenkins
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java
sudo apt install openjdk-11-jdk -y

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Install Docker
```bash
# Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### Install kubectl
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### 2. Jenkins Configuration

#### Access Jenkins
```
http://<EC2-PUBLIC-IP>:8080
```

#### Install Required Plugins
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Install:
   - Git plugin
   - Docker Pipeline plugin
   - Kubernetes plugin
   - Pipeline plugin

#### Configure Credentials
1. **DockerHub Credentials:**
   - Go to **Manage Jenkins** → **Manage Credentials**
   - Add → Username with password
   - ID: `dockerhub-credentials`
   - Username: Your DockerHub username
   - Password: Your DockerHub password

2. **Kubeconfig:**
   - Add → Secret file
   - ID: `kubeconfig`
   - File: Upload your kubeconfig file

### 3. GitHub Repository Setup

#### Fork the Repository
```bash
# Fork from: https://github.com/AKTechWiz/simple-todo-app-mongodb-express-node.git
```

#### Configure Webhook
1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. Payload URL: `http://<JENKINS-IP>:8080/github-webhook/`
4. Content type: `application/json`
5. Events: Just the push event
6. Active: ✓

### 4. DockerHub Configuration

#### Update Jenkinsfile
```groovy
// Replace in Jenkinsfile:
DOCKERHUB_USERNAME = 'YOUR_DOCKERHUB_USERNAME'
```

#### Update Kubernetes Deployment
```yaml
# In k8s/deployment.yaml, replace:
image: YOUR_DOCKERHUB_USERNAME/todo-app:latest
```

### 5. Kubernetes Cluster Setup

#### Install Kubernetes (on EC2 or separate cluster)
```bash
# Using kubeadm (Master Node)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubectl for current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 6. Create Jenkins Pipeline

#### Create New Pipeline Job
1. **Jenkins Dashboard** → **New Item**
2. Name: `todo-app-cicd`
3. Type: **Pipeline**
4. Click **OK**

#### Configure Pipeline
1. **Build Triggers:**
   - ✓ GitHub hook trigger for GITScm polling

2. **Pipeline:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/YOUR_USERNAME/simple-todo-app-mongodb-express-node.git`
   - Branch: `*/master`
   - Script Path: `Jenkinsfile`

3. **Save**

---

## Pipeline Stages Explained

### Stage 1: Code Fetch
- Clones the repository from GitHub
- Triggered automatically via GitHub webhook on push events
- Uses Git plugin to fetch latest code

### Stage 2: Build Docker Image
- Creates Docker image using Dockerfile
- Tags image with build number and 'latest'
- Uses multi-stage builds for optimization

### Stage 3: Test Docker Image
- Runs basic container tests
- Ensures image starts successfully
- Validates application health

### Stage 4: Push to DockerHub
- Authenticates with DockerHub
- Pushes both tagged and latest images
- Makes image available for deployment

### Stage 5: Deploy to Kubernetes
- Applies PVC for MongoDB persistence
- Deploys MongoDB and Todo app
- Creates LoadBalancer services
- Waits for successful rollout

### Stage 6: Setup Monitoring
- Deploys Prometheus for metrics collection
- Deploys Grafana for visualization
- Configures service discovery
- Exposes monitoring dashboards

### Stage 7: Verify Deployment
- Checks pod status
- Verifies services are running
- Displays application and monitoring URLs

---

## File Descriptions

### Dockerfile
```dockerfile
# Multi-stage Node.js application container
- Base image: node:14-alpine
- Installs production dependencies only
- Exposes port 5000
- Configures MongoDB connection
```

### k8s/pvc.yaml
```yaml
# Persistent storage for MongoDB data
- Storage: 5Gi
- Access Mode: ReadWriteOnce
- Ensures data persistence across pod restarts
```

### k8s/mongodb-deployment.yaml
```yaml
# MongoDB database deployment
- Replicas: 1
- Image: mongo:4.4
- Mounted volume for data persistence
- Resource limits configured
```

### k8s/mongodb-service.yaml
```yaml
# MongoDB internal service
- Type: ClusterIP
- Port: 27017
- Internal DNS: mongodb
```

### k8s/deployment.yaml
```yaml
# Todo application deployment
- Replicas: 2 (for high availability)
- Liveness and readiness probes
- Environment variables for MongoDB connection
- Resource requests and limits
```

### k8s/service.yaml
```yaml
# Todo app external service
- Type: LoadBalancer
- Exposes app on port 80
- Routes to container port 5000
```

### k8s/prometheus-config.yaml
```yaml
# Prometheus monitoring configuration
- Scrape interval: 15s
- Kubernetes service discovery
- Monitors pods, nodes, and services
```

### k8s/prometheus-deployment.yaml
```yaml
# Prometheus deployment
- Image: prom/prometheus:latest
- RBAC configuration for K8s discovery
- ConfigMap for configuration
```

### k8s/grafana-deployment.yaml
```yaml
# Grafana visualization platform
- Image: grafana/grafana:latest
- Default credentials: admin/admin123
- Persistent storage for dashboards
```

---

## Usage Instructions

### 1. Trigger Pipeline

#### Automatic Trigger (Recommended)
```bash
# Make changes to code
git add .
git commit -m "Your changes"
git push origin master

# Jenkins will automatically trigger the pipeline
```

#### Manual Trigger
1. Go to Jenkins Dashboard
2. Select `todo-app-cicd` job
3. Click **Build Now**

### 2. Monitor Build Progress
1. Click on build number (e.g., #1, #2)
2. Click **Console Output** to see logs
3. Watch each stage complete

### 3. Access Deployed Application

#### Get Application URL
```bash
kubectl get svc todo-app-service

# Or from Jenkins console output
```

#### Access Application
```
http://<LOAD-BALANCER-IP>
```

### 4. Access Monitoring

#### Prometheus
```bash
kubectl get svc prometheus-service

# Access at: http://<PROMETHEUS-IP>:9090
```

**Prometheus Queries:**
```promql
# CPU usage
container_cpu_usage_seconds_total

# Memory usage
container_memory_usage_bytes

# Pod count
kube_pod_info
```

#### Grafana
```bash
kubectl get svc grafana-service

# Access at: http://<GRAFANA-IP>:3000
# Default credentials: admin/admin123
```

**Setup Grafana:**
1. Login with admin/admin123
2. Add Prometheus data source:
   - URL: `http://prometheus-service:9090`
   - Access: Server
3. Import Kubernetes dashboard (ID: 315)

---

## Monitoring Metrics

### Application Metrics
- Request count
- Response time
- Error rates
- Active connections

### Infrastructure Metrics
- CPU usage per pod
- Memory consumption
- Network I/O
- Disk usage

### Database Metrics
- MongoDB connections
- Query performance
- Storage usage
- Replication lag

---

## Troubleshooting

### Jenkins Build Failures

#### Docker Build Fails
```bash
# Check Docker daemon
sudo systemctl status docker

# Check Jenkins has Docker access
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### Kubernetes Deployment Fails
```bash
# Check kubectl access
kubectl get nodes

# Verify kubeconfig in Jenkins credentials
# Check namespace exists
kubectl get namespaces
```

#### DockerHub Push Fails
```bash
# Verify credentials in Jenkins
# Test manually:
docker login
docker push <image-name>
```

### Kubernetes Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl get pods

# Describe pod for details
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

#### Service Not Accessible
```bash
# Check service
kubectl get svc

# Check if LoadBalancer assigned external IP
# May need NodePort on some cloud providers
```

#### PVC Pending
```bash
# Check PVC status
kubectl get pvc

# Check if StorageClass exists
kubectl get storageclass

# Describe PVC
kubectl describe pvc mongodb-pvc
```

### Monitoring Issues

#### Prometheus Not Scraping
```bash
# Check Prometheus targets
# Go to: http://<prometheus-ip>:9090/targets

# Verify RBAC permissions
kubectl get clusterrolebinding prometheus
```

#### Grafana No Data
```bash
# Verify Prometheus data source in Grafana
# Check Prometheus is running:
kubectl get pods -l app=prometheus
```

---

## Security Best Practices

### 1. Credentials Management
- Store all credentials in Jenkins Credentials Manager
- Never commit credentials to Git
- Use Kubernetes Secrets for sensitive data

### 2. Docker Image Security
```dockerfile
# Use specific image versions (not 'latest' in production)
FROM node:14-alpine

# Run as non-root user
USER node
```

### 3. Kubernetes Security
```yaml
# Use resource limits
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"

# Use readiness and liveness probes
# Apply network policies
# Use RBAC for access control
```

### 4. MongoDB Security
```yaml
# Use authentication
env:
- name: MONGO_INITDB_ROOT_USERNAME
  valueFrom:
    secretKeyRef:
      name: mongodb-secret
      key: username
```

---

## Performance Optimization

### 1. Docker Image Optimization
- Use alpine base images
- Multi-stage builds
- Minimize layers
- Use .dockerignore

### 2. Kubernetes Optimization
- Set appropriate resource requests/limits
- Use horizontal pod autoscaling
- Configure rolling updates
- Use readiness probes

### 3. Application Optimization
- Enable compression
- Use connection pooling for MongoDB
- Implement caching
- Optimize database queries

---

## Project Deliverables

### 1. Repository Contents
- ✅ Source code
- ✅ Dockerfile
- ✅ Jenkinsfile
- ✅ Kubernetes YAML files
- ✅ Documentation

### 2. Required Files
- ✅ `deployment.yaml` - Todo app deployment
- ✅ `service.yaml` - Todo app service
- ✅ `pvc.yaml` - Persistent volume claim
- ✅ `mongodb-deployment.yaml` - Database deployment
- ✅ `mongodb-service.yaml` - Database service
- ✅ `Jenkinsfile` - Complete CI/CD pipeline

### 3. Monitoring Configuration
- ✅ `prometheus-config.yaml` - Monitoring configuration
- ✅ `prometheus-deployment.yaml` - Prometheus setup
- ✅ `grafana-deployment.yaml` - Grafana setup

---

## Learning Outcomes Achieved

### ✅ CLO5: Apply DevOps pipeline automation techniques
- Implemented automated CI/CD pipeline using Jenkins
- Configured GitHub webhook for automated builds
- Automated Docker image creation and deployment

### ✅ Jenkins Configuration
- Installed and configured Jenkins on AWS EC2
- Configured Git integration with webhook approach
- Set up Docker and Kubernetes plugins

### ✅ Docker Integration
- Created optimized Dockerfile for Node.js application
- Built and tagged Docker images automatically
- Pushed images to DockerHub registry

### ✅ Kubernetes Deployment
- Deployed application on Kubernetes cluster
- Configured persistent storage with PVC
- Set up LoadBalancer services
- Implemented rolling updates

### ✅ Monitoring Implementation
- Deployed Prometheus for metrics collection
- Configured Grafana for visualization
- Set up Kubernetes service discovery
- Created monitoring dashboards

---

## References

1. Jenkins Documentation: https://www.jenkins.io/doc/
2. Docker Documentation: https://docs.docker.com/
3. Kubernetes Documentation: https://kubernetes.io/docs/
4. Prometheus Documentation: https://prometheus.io/docs/
5. Grafana Documentation: https://grafana.com/docs/

---

## Author

**Your Name**  
Class: BCT VII  
COMSATS University, Islamabad  
Course: CSC418 – DevOps for Cloud Computing

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Acknowledgments

- Original Todo App: Based on tutorial by Brad Traversy
- Course Instructor: Dr. Muhammad Imran
- COMSATS University, Islamabad

---

**Submission Date:** December 16, 2025  
**Project Status:** ✅ Complete
