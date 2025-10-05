pipeline {
  agent any

  environment {
    KUBECONFIG = '/var/lib/jenkins/.kube/config'
    IMAGE = "test-image"
    CONTAINER_NAME = "task-manager-test"
    ANSIBLE_DIR = "ansible"   // folder containing playbook & inventory
  }

  stages {
        stage("Checkout Code") {
            steps {
                echo "Pulling code from GitHub..."
                git branch: 'main', url: 'https://github.com/AZAL-KHAN/task_manager.git'
            }
        }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE} ."
      }
    }

    stage('Run Container') {
      steps {
        script {
          sh "docker run -d --rm --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE}"
          sh "sleep 5"

          sh '''
            if docker inspect -f "{{.State.Running}}" ${CONTAINER_NAME} | grep true; then
              echo "✅ Container is running successfully."
            else
              echo "❌ Container failed to start."
              exit 1
            fi
          '''
        }
      }
    }

    stage('Cleanup Container') {
      steps {
        sh "docker stop ${CONTAINER_NAME} || true"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh "kubectl apply -f deployment.yaml"
        sh "kubectl apply -f service.yaml"
      }
    }
  }

  post {
    success {
      echo "✅ Build and deployment completed successfully!"
    }
    failure {
      echo "❌ Something went wrong during the pipeline."
    }
  }
}
