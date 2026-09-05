pipeline {

    agent any

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
                    sh 'docker build --platform linux/amd64 -t intelliera-devops-app:1.0 .'
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

                        docker tag intelliera-devops-app:1.0 \
                        396608803308.dkr.ecr.us-east-1.amazonaws.com/intelliera-devops-app:1.0

                        docker push \
                        396608803308.dkr.ecr.us-east-1.amazonaws.com/intelliera-devops-app:1.0
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
                        apply -f kubernetes/

                        kubectl --kubeconfig "$WORKSPACE/.kube/config" \
                        rollout status deployment/intelliera-devops-app
                    '''
                }
            }
        }

    }
}
