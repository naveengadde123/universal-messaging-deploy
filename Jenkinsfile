pipeline {
    agent any

    environment {
        PROJECT_ID     = 'um-project-459607'
        CLUSTER_NAME   = 'autopilot-cluster-1'
        CLUSTER_REGION = 'us-central1'
        IMAGE_NAME     = 'um-container'
        IMAGE_TAG      = 'latest'
        GCR_IMAGE      = "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
        CREDENTIALS_ID = 'gcp-sa-key'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/naveengadde123/universal-messaging-deploy.git'
            }
        }

        stage('Authenticate with GCP') {
            steps {
                withCredentials([file(credentialsId: "${CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        echo "Authenticating with GCP..."
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
                        gcloud config set project "$PROJECT_ID"
                        gcloud auth configure-docker
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t "$GCR_IMAGE" .
                '''
            }
        }

        stage('Push Docker Image to GCR') {
            steps {
                sh '''
                    echo "Pushing Docker image to GCR..."
                    docker push "$GCR_IMAGE"
                '''
            }
        }

        stage('Deploy to GKE') {
            steps {
                sh '''
                    echo "Fetching GKE credentials for Autopilot cluster..."
                    gcloud container clusters get-credentials "$CLUSTER_NAME" \
                        --region "$CLUSTER_REGION" \
                        --project "$PROJECT_ID"

                    echo "Applying Kubernetes manifests..."
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

    post {
        failure {
            echo ' Pipeline failed!'
        }
        success {
            echo ' Pipeline completed successfully!'
        }
    }
}
