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
                git branch: 'main', url: 'https://github.com/naveengadde123/universal-messaging-deploy.git'
            }
        }

        stage('Authenticate with GCP') {
            steps {
                withCredentials([file(credentialsId: "${CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
                        gcloud config set project "$PROJECT_ID"
                        gcloud auth configure-docker
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                sh '''
                    docker build -t "$GCR_IMAGE" .
                    docker push "$GCR_IMAGE"
                '''
            }
        }

        stage('Deploy to GKE') {
            steps {
                sh '''
                    gcloud container clusters get-credentials "$CLUSTER_NAME" \
                      --region "$CLUSTER_REGION" --project "$PROJECT_ID"

                    # 1. Ensure namespace exists
                    kubectl create ns "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

                    # 2. Apply PVC
                    kubectl apply -n "$NAMESPACE" -f k8s/pvc.yaml

                    # 3. Apply ConfigMap
                    kubectl apply -n "$NAMESPACE" -f k8s/configmap.yaml

                    # 4. Deploy application
                    kubectl apply -n "$NAMESPACE" -f k8s/deployment.yaml

                    # 5. Expose service 
                    kubectl apply -n "$NAMESPACE" -f k8s/service.yaml
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
