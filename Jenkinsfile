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
                    sh 'docker build -t intelliera-devops-app:1.0 .'
                }
            }
        }

    }
}
