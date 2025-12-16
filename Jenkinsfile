pipeline {
    agent any
    
    environment {
        // DockerHub credentials - configure these in Jenkins credentials
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'YOUR_DOCKERHUB_USERNAME'
        IMAGE_NAME = 'todo-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Code Fetch') {
            steps {
                echo 'Fetching code from GitHub repository...'
                git branch: 'master',
                    url: 'https://github.com/AKTechWiz/simple-todo-app-mongodb-express-node.git'
                echo 'Code fetch completed successfully!'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    dockerImage = docker.build("${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}")
                    docker.build("${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest")
                }
                echo 'Docker image built successfully!'
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo 'Testing Docker image...'
                script {
                    // Basic test to ensure image runs
                    sh '''
                        docker run -d --name test-container ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 10
                        docker stop test-container
                        docker rm test-container
                    '''
                }
                echo 'Docker image tested successfully!'
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                echo 'Pushing Docker image to DockerHub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        dockerImage.push("${IMAGE_TAG}")
                        dockerImage.push('latest')
                    }
                }
                echo 'Docker image pushed to DockerHub successfully!'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes cluster...'
                script {
                    sh '''
                        # Update deployment image
                        sed -i "s|YOUR_DOCKERHUB_USERNAME|${DOCKERHUB_USERNAME}|g" k8s/deployment.yaml
                        sed -i "s|todo-app:latest|${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/deployment.yaml
                        
                        # Apply Kubernetes configurations
                        kubectl apply -f k8s/pvc.yaml
                        kubectl apply -f k8s/mongodb-deployment.yaml
                        kubectl apply -f k8s/mongodb-service.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for deployment to complete
                        kubectl rollout status deployment/todo-app
                        kubectl rollout status deployment/mongodb
                        
                        # Get deployment status
                        kubectl get pods
                        kubectl get services
                    '''
                }
                echo 'Application deployed to Kubernetes successfully!'
            }
        }
        
        stage('Setup Monitoring') {
            steps {
                echo 'Setting up Prometheus and Grafana monitoring...'
                script {
                    sh '''
                        # Deploy Prometheus
                        kubectl apply -f k8s/prometheus-config.yaml
                        kubectl apply -f k8s/prometheus-deployment.yaml
                        kubectl apply -f k8s/prometheus-service.yaml
                        
                        # Deploy Grafana
                        kubectl apply -f k8s/grafana-deployment.yaml
                        kubectl apply -f k8s/grafana-service.yaml
                        
                        # Wait for monitoring stack
                        kubectl rollout status deployment/prometheus
                        kubectl rollout status deployment/grafana
                        
                        echo "Prometheus URL: http://$(kubectl get svc prometheus-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9090"
                        echo "Grafana URL: http://$(kubectl get svc grafana-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):3000"
                    '''
                }
                echo 'Monitoring stack deployed successfully!'
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    sh '''
                        # Check pod status
                        kubectl get pods -l app=todo-app
                        kubectl get pods -l app=mongodb
                        
                        # Check services
                        kubectl get svc
                        
                        # Get application URL
                        echo "Application URL: http://$(kubectl get svc todo-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
                    '''
                }
                echo 'Deployment verification completed!'
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            script {
                try {
                    sh 'docker system prune -f'
                } catch (Exception e) {
                    echo "Docker cleanup skipped: ${e.message}"
                }
            }
        }
        success {
            echo 'Pipeline executed successfully!'
            echo 'Application is now running on Kubernetes cluster with monitoring enabled.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
    }
}
