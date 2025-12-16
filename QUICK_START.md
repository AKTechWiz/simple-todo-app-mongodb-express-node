# Quick Start Guide - DevOps CI/CD Pipeline Project

## 🚀 Quick Setup Checklist

### Before You Begin
- [ ] AWS EC2 instance running
- [ ] DockerHub account created
- [ ] GitHub repository forked
- [ ] kubectl configured

---

## Step 1: Update Configuration Files

### 1.1 Update Jenkinsfile
```bash
# Open Jenkinsfile and replace:
DOCKERHUB_USERNAME = 'YOUR_DOCKERHUB_USERNAME'

# With your actual DockerHub username
DOCKERHUB_USERNAME = 'yourDockerHubUsername'
```

### 1.2 Update Kubernetes Deployment
```bash
# Open k8s/deployment.yaml and replace:
image: YOUR_DOCKERHUB_USERNAME/todo-app:latest

# With your actual DockerHub username
image: yourDockerHubUsername/todo-app:latest
```

---

## Step 2: Jenkins Setup (5 minutes)

### Install Jenkins on EC2
```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@<EC2-IP>

# Run setup script
curl -fsSL https://get.jenkins.io/war-stable/latest/jenkins.war -o jenkins.war
sudo apt update && sudo apt install -y openjdk-11-jdk
sudo java -jar jenkins.war --httpPort=8080 &

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Access Jenkins
```
http://<EC2-PUBLIC-IP>:8080
```

### Install Required Plugins
1. Manage Jenkins → Manage Plugins → Available
2. Search and install:
   - Docker Pipeline
   - Kubernetes
   - Git
   - Pipeline

---

## Step 3: Configure Credentials (2 minutes)

### Add DockerHub Credentials
1. Manage Jenkins → Manage Credentials
2. Click "Add Credentials"
3. Kind: Username with password
4. ID: `dockerhub-credentials`
5. Username: Your DockerHub username
6. Password: Your DockerHub password
7. Click "OK"

### Add Kubeconfig
1. Manage Jenkins → Manage Credentials
2. Click "Add Credentials"
3. Kind: Secret file
4. ID: `kubeconfig`
5. File: Upload your ~/.kube/config file
6. Click "OK"

---

## Step 4: Create Pipeline Job (2 minutes)

### Create New Job
1. Jenkins Dashboard → New Item
2. Name: `todo-app-cicd`
3. Type: Pipeline
4. Click OK

### Configure Job
1. **General:**
   - ✓ GitHub project
   - Project url: `https://github.com/YOUR_USERNAME/simple-todo-app-mongodb-express-node`

2. **Build Triggers:**
   - ✓ GitHub hook trigger for GITScm polling

3. **Pipeline:**
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/simple-todo-app-mongodb-express-node.git`
   - Branch: `*/master`
   - Script Path: `Jenkinsfile`

4. **Save**

---

## Step 5: Setup GitHub Webhook (1 minute)

### Configure Webhook
1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: `http://<JENKINS-IP>:8080/github-webhook/`
4. Content type: `application/json`
5. Events: Just the push event
6. Active: ✓
7. Add webhook

---

## Step 6: Run First Build (1 minute)

### Trigger Build
1. Go to Jenkins Dashboard
2. Click on `todo-app-cicd`
3. Click "Build Now"

### Monitor Progress
1. Click on build #1
2. Click "Console Output"
3. Watch the pipeline execute

---

## Step 7: Access Your Application

### Get Application URL
```bash
# Wait for pipeline to complete, then:
kubectl get svc todo-app-service

# Copy the EXTERNAL-IP
```

### Open Application
```
http://<EXTERNAL-IP>
```

---

## Step 8: Access Monitoring

### Prometheus
```bash
kubectl get svc prometheus-service
# Access: http://<PROMETHEUS-IP>:9090
```

### Grafana
```bash
kubectl get svc grafana-service
# Access: http://<GRAFANA-IP>:3000
# Login: admin / admin123
```

### Setup Grafana Dashboard
1. Login to Grafana
2. Add Data Source:
   - Type: Prometheus
   - URL: `http://prometheus-service:9090`
   - Click "Save & Test"
3. Import Dashboard:
   - Click "+" → Import
   - Dashboard ID: 315
   - Select Prometheus data source
   - Click "Import"

---

## 🎯 Verification Commands

### Check All Resources
```bash
# Check all pods
kubectl get pods

# Expected output:
# NAME                        READY   STATUS    RESTARTS   AGE
# todo-app-xxxxx             1/1     Running   0          5m
# mongodb-xxxxx              1/1     Running   0          5m
# prometheus-xxxxx           1/1     Running   0          5m
# grafana-xxxxx              1/1     Running   0          5m

# Check all services
kubectl get svc

# Check PVC
kubectl get pvc
```

### Test Application
```bash
# Get app URL
export APP_URL=$(kubectl get svc todo-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test endpoint
curl http://$APP_URL
```

---

## 🔧 Common Issues & Quick Fixes

### Issue 1: Pipeline Fails at Docker Build
```bash
# Solution: Give Jenkins Docker access
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue 2: Cannot Push to DockerHub
```bash
# Solution: Verify credentials
# Re-add credentials in Jenkins with correct username/password
```

### Issue 3: Kubernetes Deployment Fails
```bash
# Solution: Check kubeconfig
kubectl get nodes

# If fails, re-add kubeconfig file in Jenkins credentials
```

### Issue 4: LoadBalancer Pending
```bash
# Solution: On some cloud providers, use NodePort instead
# Edit k8s/service.yaml:
type: NodePort
```

### Issue 5: Pods in CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name>

# Common fixes:
# 1. Check MongoDB is running
kubectl get pods -l app=mongodb

# 2. Check environment variables
kubectl describe pod <pod-name>
```

---

## 📊 Expected Results

### Successful Pipeline Output
```
✅ Stage 1: Code Fetch - SUCCESS
✅ Stage 2: Build Docker Image - SUCCESS
✅ Stage 3: Test Docker Image - SUCCESS
✅ Stage 4: Push to DockerHub - SUCCESS
✅ Stage 5: Deploy to Kubernetes - SUCCESS
✅ Stage 6: Setup Monitoring - SUCCESS
✅ Stage 7: Verify Deployment - SUCCESS

Pipeline executed successfully!
```

### Deployed Resources
- ✅ 2 Todo App pods (replicas)
- ✅ 1 MongoDB pod
- ✅ 1 Prometheus pod
- ✅ 1 Grafana pod
- ✅ 4 Services (LoadBalancer)
- ✅ 1 PersistentVolumeClaim

---

## 🎓 For Your Report

### Screenshots to Include
1. Jenkins Dashboard showing successful pipeline
2. Console output of complete pipeline execution
3. DockerHub showing pushed images
4. Kubernetes pods running (kubectl get pods)
5. Kubernetes services (kubectl get svc)
6. Todo app running in browser
7. Prometheus dashboard
8. Grafana dashboard with metrics

### Files to Submit
1. ✅ Jenkinsfile
2. ✅ Dockerfile
3. ✅ k8s/deployment.yaml
4. ✅ k8s/service.yaml
5. ✅ k8s/pvc.yaml
6. ✅ k8s/mongodb-deployment.yaml
7. ✅ k8s/mongodb-service.yaml
8. ✅ k8s/prometheus-*.yaml
9. ✅ k8s/grafana-*.yaml
10. ✅ PROJECT_DOCUMENTATION.md

---

## 🚀 Next Steps After Setup

### 1. Test the Pipeline
```bash
# Make a change to README.md
echo "# Test change" >> README.md
git add .
git commit -m "Test pipeline trigger"
git push origin master

# Watch Jenkins automatically trigger build
```

### 2. Explore Monitoring
- View Prometheus targets
- Create Grafana dashboards
- Set up alerts

### 3. Test High Availability
```bash
# Delete a pod and watch it recreate
kubectl delete pod <todo-app-pod-name>
kubectl get pods -w
```

### 4. Scale the Application
```bash
# Scale to 5 replicas
kubectl scale deployment todo-app --replicas=5
kubectl get pods
```

---

## 📞 Need Help?

### Check Logs
```bash
# Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Kubernetes pod logs
kubectl logs <pod-name>

# Describe resources
kubectl describe deployment todo-app
kubectl describe svc todo-app-service
```

### Useful Commands
```bash
# Restart deployment
kubectl rollout restart deployment todo-app

# View deployment history
kubectl rollout history deployment todo-app

# Rollback deployment
kubectl rollout undo deployment todo-app

# Delete all resources
kubectl delete -f k8s/
```

---

## ✅ Success Criteria

Your project is successful when:
- ✅ Pipeline runs without errors
- ✅ Application is accessible via browser
- ✅ MongoDB stores data persistently
- ✅ Prometheus collects metrics
- ✅ Grafana displays dashboards
- ✅ Webhook triggers builds automatically

---

**Time to Complete:** ~15-20 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Basic knowledge of Jenkins, Docker, Kubernetes

Good luck with your project! 🎉
