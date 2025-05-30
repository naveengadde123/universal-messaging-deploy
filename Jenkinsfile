pipeline {
    agent any
    environment {
        PROJECT_ID     = 'um-project-459607'
        CLUSTER_NAME   = 'autopilot-cluster-1'
        CLUSTER_REGION = 'us-central1'
        IMAGE_NAME     = 'um-container'
        IMAGE_TAG      = 'latest'
        GCR_IMAGE      = "us-central1-docker.pkg.dev/${PROJECT_ID}/um-container-repo/${IMAGE_NAME}:${IMAGE_TAG}"
        CREDENTIALS_ID = 'gcp-sa-key'
        NAMESPACE      = 'um-deployment'
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
                    kubectl wait --for=condition=available deployment/deployment-1 -n "${NAMESPACE}" --timeout=600s
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
                    if (podStatus.contains("CrashLoopBackOff") || podStatus.contains("Pending") || podStatus.contains("ContainerCreating")) {
                        error "Some pods are in CrashLoopBackOff, Pending, or ContainerCreating"
                    }
                }
            }
        }
        stage('Test UM Connectivity') {
            steps {
                script {
                    try {
                        sh "kubectl run -i --rm debug-pod --image=busybox --restart=Never -n ${NAMESPACE} -- wget -qO- http://deployment-1-service.${NAMESPACE}.svc.cluster.local:9001"
                        echo 'Internal UM Admin connectivity test passed'
                    } catch (Exception e) {
                        echo "Internal UM Admin connectivity test failed: ${e}"
                    }
                    try {
                        sh "kubectl run -i --rm debug-pod --image=busybox --restart=Never -n ${NAMESPACE} -- nc -v -w 2 deployment-1-service.${NAMESPACE}.svc.cluster.local 9900"
                        echo 'Internal UM TCP connectivity test passed'
                    } catch (Exception e) {
                        echo "Internal UM TCP connectivity test failed: ${e}"
                    }
                    try {
                        sh "curl --retry 3 --retry-delay 5 http://${EXTERNAL_IP}:9001"
                        echo 'External UM Admin connectivity test passed'
                    } catch (Exception e) {
                        echo "External UM Admin connectivity test failed: ${e}"
                    }
                }
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