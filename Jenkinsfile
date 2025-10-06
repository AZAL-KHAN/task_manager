pipeline {
    agent any
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        IMAGE = "task-tracker:01"
        CONTAINER_NAME = "task-manager-test"
        ANSIBLE_DIR = "ansible"
        DOCKER_REPO = "khanazal"
        DOCKER_CREDENTIALS = "docker-hub-credentials"
    }

    stages {
        stage("Checkout Code") {
            steps {
                echo "Pulling code from GitHub..."
                git branch: 'main', url: 'https://github.com/AZAL-KHAN/task_manager.git'
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t ${DOCKER_REPO}/${IMAGE} ."
            }
        }

        stage('Run and Test Container') {
            steps {
                script {
                    sh """
                        docker run -d --rm --name ${CONTAINER_NAME} -p 5000:5000 ${DOCKER_REPO}/${IMAGE}
                        sleep 5
                        if docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} | grep true; then
                            echo "✅ Container is running successfully."
                        else
                            echo "❌ Container failed to start."
                            exit 1
                        fi
                    """
                }
            }
        }

        stage('Cleanup Test Container') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
            }
        }

        stage('Push Docker Image to Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh """
                        docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                        docker push ${DOCKER_REPO}/${IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def k8sStatus = sh(script: "kubectl apply -f k8s/", returnStatus: true)
                    
                    if (k8sStatus == 0) {
                        echo "✅ App successfully deployed to Kubernetes!"
                    } else {
                        error("❌ Kubernetes deployment failed!")
                    }
                }
            }
        }

        stage('Ansible EC2 Deployment') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sshagent(['aws-ec2-key']) {
                        script {
                            def ansibleStatus = sh(script: "ansible-playbook -i inventory_aws.ini deploy_flask.yml", returnStatus: true)
                            
                            if (ansibleStatus == 0) {
                                echo "✅ App deployed to AWS EC2 successfully!"
                            } else {
                                error("❌ App deployment to AWS EC2 failed!")
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Something went wrong during the pipeline execution!"
        }
    }
}
