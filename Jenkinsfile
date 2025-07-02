pipeline {
    agent any

    environment {
        // Jenkins credentials (must be created in Jenkins)
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        KUBECONFIG_CREDENTIAL = credentials('kubeconfig-file') // if needed by kubectl
        ARGOCD_TOKEN = credentials('argocd-token')    // ArgoCD API token
        IMAGE_NAME = "y16me910/yourapp"
        SONARQUBE_SERVER = 'Sonarqube' // Name configured in Jenkins global tools
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/y16me91o/app-repo.git'
            }
        }



        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        docker.image("${IMAGE_NAME}:${env.BUILD_ID}").push()
                        docker.image("${IMAGE_NAME}:${env.BUILD_ID}").tag('latest')
                        docker.image("${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('Update Kubernetes YAML and Commit') {
            steps {
                sshagent(['git-ssh-key']) {
                    sh """
                        sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${env.BUILD_ID}|' kubernetes/deployment.yaml
                        git config user.name "jenkins"
                        git config user.email "jenkins@domain.com"
                        git remote set-url origin git@github.com:y16me91o/app-repo.git
                        git add kubernetes/deployment.yaml
                        git commit -m "Update image to ${IMAGE_NAME}:${env.BUILD_ID}"
                        git push origin main
                    """
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                   withCredentials([string(credentialsid: 'argocd-token', variable: 'ARGOCD_TOKEN')]) { 
                   sh """
                        curl -X POST -k https://localhost:8090/api/v1/applications/yourapp/sync \
                          -H "Authorization: Bearer $ARGOCD_TOKEN"
                    """
                }
            }
        }
    }
    }      

    post {
        success {
            echo "Pipeline completed successfully. Deployment will be synced by ArgoCD."
        }
        failure {
            echo "Pipeline failed. Please check the console output for errors."
        }
    }
}

