pipeline {

    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        ECR_REGISTRY = "396608803308.dkr.ecr.us-east-1.amazonaws.com"
        ECR_REPOSITORY = "intelliera-devops-app"
    }

    stages {

        stage('Build with Maven') {
            steps {
                dir('application') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('application') {
                    sh 'docker build --platform linux/amd64 -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        export AWS_DEFAULT_REGION=us-east-1
                        export DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib

                        aws ecr get-login-password --region us-east-1 | \
                        docker login --username AWS --password-stdin \
                        396608803308.dkr.ecr.us-east-1.amazonaws.com

                        docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
                        ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

                        docker push \
                        ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-ecr',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        export AWS_DEFAULT_REGION=us-east-1
                        export DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib

                        mkdir -p "$WORKSPACE/.kube"

                        aws eks update-kubeconfig \
                        --name intelliera-devops-cluster \
                        --region us-east-1 \
                        --kubeconfig "$WORKSPACE/.kube/config"

                        kubectl --kubeconfig "$WORKSPACE/.kube/config" \
                        set image deployment/intelliera-devops-app \
                        intelliera-devops-app=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

                        kubectl --kubeconfig "$WORKSPACE/.kube/config" \
                        rollout status deployment/intelliera-devops-app
                    '''
                }
            }
        }

    }
}
