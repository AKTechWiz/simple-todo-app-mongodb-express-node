# 🎯 NEXT STEPS - What You Need to Do Now

## ✅ All Files Created Successfully!

Git has been installed and all project files have been created. Here's what you need to do next:

---

## 📝 STEP 1: Update Your Configuration (5 minutes)

### 1.1 Update Jenkinsfile
Open `Jenkinsfile` and find line 8:
```groovy
DOCKERHUB_USERNAME = 'YOUR_DOCKERHUB_USERNAME'
```

Replace with your actual DockerHub username:
```groovy
DOCKERHUB_USERNAME = 'yourusername'
```

### 1.2 Update Kubernetes Deployment
Open `k8s/deployment.yaml` and find line 20:
```yaml
image: YOUR_DOCKERHUB_USERNAME/todo-app:latest
```

Replace with your actual DockerHub username:
```yaml
image: yourusername/todo-app:latest
```

---

## 🚀 STEP 2: Push to Your GitHub Repository

Since you forked the repository, you need to push these new files to your fork:

```powershell
# Navigate to project directory
cd simple-todo-app-mongodb-express-node

# Configure git (if not already done)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add all new files
git add .

# Commit the changes
git commit -m "Add DevOps CI/CD pipeline with Jenkins, Docker, Kubernetes, Prometheus, and Grafana"

# Push to your fork
git push origin master
```

If you get an authentication error, you may need to use a Personal Access Token:
1. Go to GitHub → Settings → Developer Settings → Personal Access Tokens
2. Generate a new token with 'repo' scope
3. Use the token as your password when pushing

---

## ☁️ STEP 3: Setup AWS EC2 Instance for Jenkins

### Option A: Launch EC2 Instance from AWS Console
1. Login to AWS Console
2. EC2 → Launch Instance
3. **Settings:**
   - Name: jenkins-server
   - AMI: Ubuntu Server 20.04 LTS
   - Instance Type: t2.medium (minimum)
   - Key pair: Create or select existing
   - Security Group: Allow ports 22, 8080, 80, 443
4. Launch instance

### Option B: Use Existing EC2 Instance
If you already have an EC2 instance, ensure it meets:
- Memory: At least 4GB RAM
- Ports: 8080 open for Jenkins
- OS: Ubuntu/Linux

---

## 🔧 STEP 4: Install Jenkins on EC2

SSH into your EC2 instance:
```bash
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

Then run these commands:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add Jenkins to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Get Jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Save the password that appears!

---

## 🌐 STEP 5: Access Jenkins

1. Open browser and go to: `http://<EC2-PUBLIC-IP>:8080`
2. Enter the initial admin password from previous step
3. Click "Install suggested plugins"
4. Create admin user
5. Click "Start using Jenkins"

---

## 🔌 STEP 6: Install Jenkins Plugins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Click **Available** tab
3. Search and install:
   - Docker Pipeline
   - Kubernetes
   - Pipeline
   - Git
4. Click "Install without restart"
5. Wait for installation to complete

---

## 🔑 STEP 7: Configure Jenkins Credentials

### 7.1 Add DockerHub Credentials
1. **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **Add Credentials**
4. Fill in:
   - Kind: `Username with password`
   - Username: Your DockerHub username
   - Password: Your DockerHub password
   - ID: `dockerhub-credentials`
   - Description: DockerHub Login
5. Click **OK**

### 7.2 Add Kubeconfig (if using Kubernetes cluster)
1. **Manage Jenkins** → **Manage Credentials**
2. Click **Add Credentials**
3. Fill in:
   - Kind: `Secret file`
   - File: Upload your kubeconfig file (from ~/.kube/config)
   - ID: `kubeconfig`
   - Description: Kubernetes Config
4. Click **OK**

---

## 📋 STEP 8: Create Jenkins Pipeline Job

1. **Jenkins Dashboard** → **New Item**
2. **Enter name:** `todo-app-cicd`
3. **Select:** Pipeline
4. Click **OK**

### Configure the Pipeline:

#### General Section:
- ✓ Check **GitHub project**
- Project url: `https://github.com/YOUR_USERNAME/simple-todo-app-mongodb-express-node`

#### Build Triggers:
- ✓ Check **GitHub hook trigger for GITScm polling**

#### Pipeline Section:
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/YOUR_USERNAME/simple-todo-app-mongodb-express-node.git`
- Credentials: (leave as none if public repo)
- Branch Specifier: `*/master`
- Script Path: `Jenkinsfile`

5. Click **Save**

---

## 🪝 STEP 9: Setup GitHub Webhook

1. Go to your GitHub repository
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Fill in:
   - Payload URL: `http://<JENKINS-EC2-IP>:8080/github-webhook/`
   - Content type: `application/json`
   - Which events: `Just the push event`
   - ✓ Active
4. Click **Add webhook**
5. You should see a green checkmark if successful

---

## ▶️ STEP 10: Run Your First Build!

### Option A: Manual Trigger
1. Go to Jenkins Dashboard
2. Click on `todo-app-cicd`
3. Click **Build Now**
4. Watch the build progress

### Option B: Automatic Trigger (Recommended)
```powershell
# Make a small change to test webhook
cd simple-todo-app-mongodb-express-node
echo "# CI/CD Pipeline Active" >> README.md
git add README.md
git commit -m "Test webhook trigger"
git push origin master

# Jenkins should automatically start building!
```

---

## 📊 STEP 11: Monitor the Build

1. Click on the build number (e.g., #1)
2. Click **Console Output**
3. Watch the logs as each stage executes:
   - ✅ Code Fetch
   - ✅ Build Docker Image
   - ✅ Test Docker Image
   - ✅ Push to DockerHub
   - ✅ Deploy to Kubernetes
   - ✅ Setup Monitoring
   - ✅ Verify Deployment

---

## 🎉 STEP 12: Access Your Application

Once the build completes successfully:

```bash
# SSH to your K8s cluster or Jenkins server
kubectl get svc todo-app-service

# Note the EXTERNAL-IP
# Open in browser: http://<EXTERNAL-IP>
```

---

## 📈 STEP 13: Access Monitoring

### Prometheus:
```bash
kubectl get svc prometheus-service
# Open: http://<PROMETHEUS-IP>:9090
```

### Grafana:
```bash
kubectl get svc grafana-service
# Open: http://<GRAFANA-IP>:3000
# Login: admin / admin123
```

Setup Grafana:
1. Add Data Source → Prometheus
2. URL: `http://prometheus-service:9090`
3. Click "Save & Test"
4. Import Dashboard (ID: 315)

---

## 📸 STEP 14: Take Screenshots for Your Report

Capture these screenshots:

1. ✅ Jenkins Dashboard with successful build
2. ✅ Pipeline stage view (all green)
3. ✅ Console output showing all stages
4. ✅ DockerHub repository with image
5. ✅ `kubectl get pods` output
6. ✅ `kubectl get svc` output
7. ✅ `kubectl get pvc` output
8. ✅ Todo app in browser (homepage)
9. ✅ User registration screen
10. ✅ Todo list with items
11. ✅ Prometheus UI showing targets
12. ✅ Grafana dashboard with metrics

---

## 📝 STEP 15: Write Your Report

Use the template in `PROJECT_DOCUMENTATION.md` as reference. Your report should include:

1. **Cover Page**
   - Project title
   - Your name and class
   - Date

2. **Introduction** (1 page)
   - Project overview
   - Objectives

3. **Application Description** (1 page)
   - Todo app features
   - Technologies used

4. **Implementation Steps** (3-4 pages)
   - Jenkins setup
   - Docker configuration
   - Kubernetes deployment
   - Pipeline creation
   - Monitoring setup

5. **Configuration Files** (2-3 pages)
   - Jenkinsfile explanation
   - Dockerfile breakdown
   - Kubernetes YAML files

6. **Screenshots with Explanations** (3-4 pages)
   - Each screenshot with description

7. **Challenges & Solutions** (1 page)
   - Problems faced
   - How you solved them

8. **Results** (1 page)
   - Successful deployment
   - Application working
   - Monitoring active

9. **Conclusion** (1 page)
   - Learning outcomes
   - Future improvements

---

## 📦 STEP 16: Prepare Submission

Create a folder with:
```
DevOps_Project_YourName/
├── Report.pdf
├── Screenshots/
│   ├── 01_jenkins_dashboard.png
│   ├── 02_pipeline_stages.png
│   ├── 03_console_output.png
│   ├── ... (all screenshots)
├── Code/
│   ├── Jenkinsfile
│   ├── Dockerfile
│   ├── .dockerignore
│   └── k8s/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── pvc.yaml
│       ├── mongodb-deployment.yaml
│       ├── mongodb-service.yaml
│       ├── prometheus-*.yaml
│       └── grafana-*.yaml
└── README.md (optional)
```

---

## ✅ Final Checklist

Before submission, verify:

- [ ] All configuration files updated with your credentials
- [ ] Code pushed to your GitHub fork
- [ ] Jenkins installed and running on EC2
- [ ] All Jenkins plugins installed
- [ ] Credentials configured in Jenkins
- [ ] Pipeline job created
- [ ] GitHub webhook configured
- [ ] At least one successful build completed
- [ ] Application accessible via browser
- [ ] Monitoring dashboards accessible
- [ ] All required screenshots taken
- [ ] Report written and formatted
- [ ] All files included in submission folder

---

## 🆘 Need Help?

### Common Issues:

**Jenkins can't access Docker:**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**Webhook not triggering:**
- Check webhook URL is correct
- Ensure port 8080 is open on EC2
- Check webhook delivery in GitHub settings

**Pipeline fails at K8s deployment:**
- Verify kubeconfig is correct
- Test kubectl commands manually
- Check if cluster is accessible

**Can't access application:**
- Wait for LoadBalancer to assign external IP
- Use NodePort if LoadBalancer not supported
- Check security group rules

### Documentation:
- **Complete Guide:** `PROJECT_DOCUMENTATION.md`
- **Quick Start:** `QUICK_START.md`
- **Summary:** `PROJECT_SUMMARY.md`

---

## 🎓 Important Notes

1. **Replace placeholders:** Don't forget to replace YOUR_DOCKERHUB_USERNAME
2. **Test locally first:** Try building Docker image locally before pipeline
3. **Keep credentials safe:** Never commit credentials to Git
4. **Document everything:** Take notes as you go
5. **Test before submitting:** Ensure everything works end-to-end

---

## 🏆 Success Criteria

Your project is successful when:
- ✅ Pipeline runs without errors
- ✅ Application is live and accessible
- ✅ Database stores data persistently
- ✅ Monitoring shows metrics
- ✅ Webhook triggers builds automatically

---

**Time Estimate:**
- Configuration updates: 10 minutes
- AWS & Jenkins setup: 45 minutes
- Pipeline creation: 15 minutes
- First build & testing: 20 minutes
- Screenshots & report: 2-3 hours

**Total: ~4 hours**

---

## 📞 Support

If you get stuck:
1. Check Console Output in Jenkins for error details
2. Look at pod logs: `kubectl logs <pod-name>`
3. Review troubleshooting section in PROJECT_DOCUMENTATION.md
4. Google the specific error message

---

**Good luck with your project! You've got this! 🚀**

Remember: All the hard work of creating files is done. Now you just need to configure and deploy!

---

**Last Updated:** December 16, 2025  
**Project Status:** ✅ Files Ready - Pending Deployment
