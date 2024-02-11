pipeline {
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        GIT_REPO_NAME = "Tetris-manifest"
        GIT_USER_NAME = "SaiPisey2"
      }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SaiPisey2/Tetris-V2.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=tetrisV2 \
                    -Dsonar.projectKey=tetrisV2 '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('NPM install') {
            steps {
                sh 'npm install'
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Docker build and push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh '''
                        docker build -t spisey/tetrisv2:latest .
                        docker push spisey/tetrisv2:latest
                        '''
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image spisey/tetrisv2:latest > trivyimage.txt'
            }
        }
        stage('Checkout Manifests') {
            steps {
                git branch: 'main', url: 'https://github.com/SaiPisey2/Tetris-manifest.git'
            }
        }
        stage('Update Deployment File') {
          steps {
                script {
                  withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                    // Determine the image name dynamically based on your versioning strategy
                    NEW_IMAGE_NAME = "spisey/tetrisv2:latest"
        
                    // Replace the image name in the deployment.yaml file
                    sh "sed -i 's|image: .*|image: $NEW_IMAGE_NAME|' deployment.yml"
        
                    // Git commands to stage, commit, and push the changes
                    sh 'git add deployment.yml'
                    sh "git commit -m 'Update deployment image to $NEW_IMAGE_NAME'"
                    sh "git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main"
                    }
                }
            }
        }
    }
}
