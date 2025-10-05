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
        script {
          def k8sStatus = sh(script: "kubectl apply -f k8s/deployment.yaml && kubectl apply -f k8s/service.yaml", returnStatus: true)
          if (k8sStatus == 0) {
            echo "✅ App successfully deployed through Kubernetes!"
          } else {
            error("❌ App deployment through Kubernetes failed!")
          }
        }
      }
    }

    stage('Deploy to VM via Ansible') {
      steps {
        dir("${ANSIBLE_DIR}") {
          sshagent(['aws-ec2-key']) {
            script {
              def ansibleStatus = sh(script: "ansible-playbook -i inventory_aws.ini deploy_flask.yml", returnStatus: true)
              if (ansibleStatus == 0) {
                echo "✅ App deployed successfully to AWS EC2 via Ansible!"
              } else {
                error("❌ App deployment to AWS EC2 via Ansible failed!")
              }
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully — all deployments passed!"
    }
    failure {
      echo "❌ Something went wrong during the pipeline execution!"
    }
  }
}
