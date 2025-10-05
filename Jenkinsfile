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

    stage('Run Container (Test)') {
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

    stage('Cleanup Test Container') {
      steps {
        sh "docker stop ${CONTAINER_NAME} || true"
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh "kubectl apply -f k8s/deployment.yaml"
        sh "kubectl apply -f k8s/service.yaml"
      }
    }

    stage('Deploy to VM via Ansible') {
      steps {
        dir("${ANSIBLE_DIR}") {
          // sh "ansible-playbook -i inventory.ini deploy_flask.yml"
          sh "ansible-playbook -i inventory_aws.ini deploy_flask.yml"
        }
      }
    }

  }

  post {
    success {
      echo "✅ Build, K8s, and Ansible deployments completed successfully!"
    }
    failure {
      echo "❌ Something went wrong during the pipeline."
    }
  }
}
