pipeline {
    agent any

    environment {
        PROJECT_ID = 'um-project-459607'
        CLUSTER_NAME = 'autopilot-cluster-1'
        CLUSTER_ZONE = 'us-central1-a'
        IMAGE_NAME = 'um-container'
        IMAGE_TAG = 'latest'
        GCR_IMAGE = "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}"
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
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project $PROJECT_ID
                        gcloud auth configure-docker
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $GCR_IMAGE .
                '''
            }
        }

        stage('Push Docker Image to GCR') {
            steps {
                sh '''
                    docker push $GCR_IMAGE
                '''
            }
        }

        stage('Deploy to GKE') {
            steps {
                sh '''
                    gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }
}
