pipeline {
    agent any
    environment {
        // Define environment variables
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '851725499582'
        FRONTEND_ECR_REPOSITORY = 'frontend'
        BACKEND_ECR_REPOSITORY = 'backend'
        FRONTEND_IMAGE_TAG = "frontend-${env.BUILD_ID}"
        BACKEND_IMAGE_TAG = "backend-${env.BUILD_ID}"
        ECS_CLUSTER_NAME = 'ecstest'
        FRONTEND_SERVICE_NAME = 'frontend-service1'
        BACKEND_SERVICE_NAME = 'backend-service1'
        FRONTEND_REPO_URL = 'https://github.com/chrlsC08/Jenkins-DemoFront.git'
        BACKEND_REPO_URL = 'https://github.com/chrlsC08/Jenkins-DemoBack.git'
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Clone Repositories') {
            parallel {
                stage('Clone Frontend Repository') {
                    steps {
                        dir('frontend') {
                            git url: "${env.FRONTEND_REPO_URL}", branch: 'main'
                        }
                    }
                }
                stage('Clone Backend Repository') {
                    steps {
                        dir('backend') {
                            git url: "${env.BACKEND_REPO_URL}", branch: 'main'
                        }
                    }
                }
            }
        }
        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend Image') {
                    steps {
                        script {
                            docker.build("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.FRONTEND_ECR_REPOSITORY}:${env.FRONTEND_IMAGE_TAG}", '-f Dockerfile .')
                        }
                    }
                }
                stage('Build Backend Image') {
                    steps {
                        script {
                            docker.build("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.BACKEND_ECR_REPOSITORY}:${env.BACKEND_IMAGE_TAG}", '-f backend/Dockerfile .')
                        }
                    }
                }
            }
        }
        stage('Login to AWS ECR') {
            steps {
                script {
                    sh '$(aws ecr get-login --no-include-email --region $AWS_REGION)'
                }
            }
        }
        stage('Push Docker Images') {
            parallel {
                stage('Push Frontend Image') {
                    steps {
                        script {
                            docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com", 'ecr:us-east-1:aws-credentials') {
                                docker.image("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.FRONTEND_ECR_REPOSITORY}:${env.FRONTEND_IMAGE_TAG}").push()
                            }
                        }
                    }
                }
                stage('Push Backend Image') {
                    steps {
                        script {
                            docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com", 'ecr:us-east-1:aws-credentials') {
                                docker.image("${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.BACKEND_ECR_REPOSITORY}:${env.BACKEND_IMAGE_TAG}").push()
                            }
                        }
                    }
                }
            }
        }
        stage('Deploy to ECS') {
            parallel {
                stage('Deploy Frontend Service') {
                    steps {
                        script {
                            sh """
                            aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $FRONTEND_SERVICE_NAME --force-new-deployment --region $AWS_REGION
                            """
                        }
                    }
                }
                stage('Deploy Backend Service') {
                    steps {
                        script {
                            sh """
                            aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $BACKEND_SERVICE_NAME --force-new-deployment --region $AWS_REGION
                            """
                        }
                    }
                }
            }
        }
    }
}
