pipeline {
    agent { label 'jenkins-slave' }

    environment {
        DOCKERHUB_REPOSITORY_NAME = 'mycoolwebapp'
    }

    stages {
        stage('Run Unit tests') {
            steps {
                checkout scm
                sh 'docker compose build test-runner'
                sh 'docker compose run --rm --entrypoint pytest test-runner'
            }
        }

        stage('Build and Push') {
            steps {
                checkout scm
                withCredentials([
                    usernamePassword(
                        credentialsId: 'DOCKERHUB_CREDENTIALS',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh """
                        docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN
                        docker buildx create --use
                        docker buildx build --platform linux/amd64,linux/arm64 \
                            -t $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:${env.GIT_COMMIT.take(7)} \
                            --push \
                            ./api
                    """
                }
            }
        }


        stage('Transfer Files') {
                steps {
                    checkout scm
                    withCredentials([
                        sshUserPrivateKey(credentialsId: '9f2311c8-36a3-4814-a6a2-2bc6338f19ad', keyFileVariable: 'SSH_PRIVATE_KEY', usernameVariable: 'SSH_USER'),
                        string(credentialsId: 'INSTANCE_IP', variable: 'DEPLOYMENT_SERVER_IP')
                    ]) {
                        sh """
                            git rev-parse --short HEAD > version.txt
                            chmod 600 "$SSH_PRIVATE_KEY"
                            scp -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no \
                                docker-compose.production.yaml nginx.conf version.txt \
                                $SSH_USER@$DEPLOYMENT_SERVER_IP:~/ 
                        """
                    }
                }
        }

        stage('Run Deployment') {
            steps {
                checkout scm
                withCredentials([
                    sshUserPrivateKey(credentialsId: '9f2311c8-36a3-4814-a6a2-2bc6338f19ad', keyFileVariable: 'SSH_PRIVATE_KEY', usernameVariable: 'SSH_USER'),
                    string(credentialsId: 'INSTANCE_IP', variable: 'DEPLOYMENT_SERVER_IP')
                ]) {
                    sh """

                        chmod 600 "$SSH_PRIVATE_KEY"
                        ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no \
                            $SSH_USER@$DEPLOYMENT_SERVER_IP \
                            "COMMIT_HASH=\$(cat version.txt) docker compose -f ~/docker-compose.production.yaml up -d"
                    """
                    }
                }
            }
        }

}
