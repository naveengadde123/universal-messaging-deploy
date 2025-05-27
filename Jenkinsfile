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
        NAMESPACE      = 'um-deployment'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out source code..."
                git branch: 'main', url: 'https://github.com/naveengadde123/universal-messaging-deploy.git'
            }
        }

        stage('Authenticate with GCP') {
            steps {
                withCredentials([file(credentialsId: "${CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    echo "Authenticating with GCP..."
                    sh '''
                        set -e
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
                        gcloud config set project "$PROJECT_ID"
                        gcloud auth configure-docker
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                echo "Building and pushing Docker image to Google Container Registry..."
                sh '''
                    set -e
                    docker build -t "$GCR_IMAGE" .
                    docker push "$GCR_IMAGE"
                '''
            }
        }

        stage('Deploy to GKE') {
            steps {
                echo "Deploying application to GKE cluster..."
                sh '''
                    set -e
                    gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_REGION" --project "$PROJECT_ID"

                    echo "Ensuring namespace '${NAMESPACE}' exists..."
                    kubectl create ns "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

                    echo "Applying PersistentVolumeClaim..."
                    kubectl apply -n "$NAMESPACE" -f k8s/pvc.yaml

                    echo "Applying ConfigMap..."
                    kubectl apply -n "$NAMESPACE" -f k8s/configmap.yaml

                    echo "Deploying application..."
                    kubectl apply -n "$NAMESPACE" -f k8s/deployment.yaml

                    echo "Exposing service..."
                    kubectl apply -n "$NAMESPACE" -f k8s/service.yaml

                    echo "Waiting for deployment rollout to finish..."
                    kubectl rollout status deployment/deployment-1 -n "$NAMESPACE"
                '''
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline failed!'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
    }
}
