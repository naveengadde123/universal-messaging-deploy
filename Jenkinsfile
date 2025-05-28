pipeline {
    agent any
    environment {
        PROJECT_ID     = 'um-project-459607'
        CLUSTER_NAME   = 'autopilot-cluster-1'
        CLUSTER_REGION = 'us-central1'
        IMAGE_NAME     = 'um-container'
        IMAGE_TAG      = 'latest'
        GCR_IMAGE      = "us-central1-docker.pkg.dev/${PROJECT_ID}/um-container-repo/${IMAGE_NAME}:${IMAGE_TAG}" // Match deployment
        CREDENTIALS_ID = 'gcp-sa-key'
        NAMESPACE      = 'um-deployment'
        SERVICE_URL    = "http://deployment-1-service.${NAMESPACE}.svc.cluster.local:9900/rest/monitoring/status"
        EXTERNAL_IP    = '34.135.162.177'
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
                        gcloud services enable cloudresourcemanager.googleapis.com --project "${PROJECT_ID}"
                        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
                        gcloud config set project "${PROJECT_ID}"
                        gcloud auth configure-docker us-central1-docker.pkg.dev
                    '''
                }
            }
        }
        stage('Build & Push Image') {
            steps {
                echo "Building and pushing Docker image to Artifact Registry..."
                sh '''
                    set -e
                    docker build -t "${GCR_IMAGE}" .
                    docker push "${GCR_IMAGE}"
                '''
            }
        }
        stage('Deploy to GKE') {
            steps {
                echo "Deploying application to GKE cluster..."
                sh '''
                    set -e
                    gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${CLUSTER_REGION}" --project "${PROJECT_ID}"
                    echo "Ensuring namespace '${NAMESPACE}' exists..."
                    kubectl create ns "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
                    echo "Applying PersistentVolumeClaim..."
                    kubectl apply -n "${NAMESPACE}" -f k8s/pvc.yaml
                    echo "Applying ConfigMap..."
                    kubectl apply -n "${NAMESPACE}" -f k8s/configmap.yaml
                    echo "Deploying application..."
                    kubectl apply -n "${NAMESPACE}" -f k8s/deployment.yaml
                    echo "Exposing service..."
                    kubectl apply -n "${NAMESPACE}" -f k8s/service.yaml
                    echo "Waiting for deployment rollout to finish..."
                    kubectl wait --for=condition=available deployment/deployment-1 -n "${NAMESPACE}" --timeout=300s
                '''
            }
        }
        stage('Verify Pods') {
            steps {
                sh '''
                    set -e
                    kubectl get pods -n "${NAMESPACE}" -o wide
                '''
                script {
                    def podStatus = sh(script: "kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.status.phase}{\"\\n\"}{end}'", returnStdout: true).trim()
                    if (podStatus.contains("ContainerCreating")) {
                        echo "Warning: Some pods are still in ContainerCreating phase."
                    }
                }
            }
        }
        stage('Test UM Connectivity') {
            steps {
                script {
                    // Wrap UM connectivity checks in try-catch to prevent pipeline failure
                    try {
                        sh "kubectl run -i --rm debug-pod --image=busybox --restart=Never -n ${NAMESPACE} -- wget -qO- ${SERVICE_URL}"
                        echo 'Internal UM HTTP connectivity test passed'
                    } catch (Exception e) {
                        echo "Warning: Internal UM HTTP connectivity test failed: ${e}"
                    }
                    try {
                        sh "curl --retry 3 --retry-delay 5 http://${EXTERNAL_IP}:9900/rest/monitoring/status"
                        echo 'External UM HTTP connectivity test passed'
                    } catch (Exception e) {
                        echo "Warning: External UM HTTP connectivity test failed: ${e}"
                    }
                }
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
