pipeline {

    agent any

    parameters {
        string( name: 'NEXUS_URL', 
                defaultValue: 'http://nexus3:8081', 
                description: 'URL of the Nexus server')
    }

    environment {
        IMAGE_NAME = 'simple-get-jee7'
        DOCKER_REGISTRY_URL = 'http://${params.NEXUS_URL}/repository/epic-docker-repo/'
    }

    tools {
        maven 'maven-3.6.0'
        jdk 'jdk8'
    }

    stages {
        stage ('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/TEST-*.xml'
                }
            }
        }
        stage("Code Quality Analysis") {
            stages {
                stage("SonarQube - analysis") {
                    steps {
                        withSonarQubeEnv('SonarQube Server') {
                            sh  '''
                                mvn $SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL
                                '''
                        }
                    }
                }
                stage("SonarQube - Quality Gate") {
                    steps {
                        timeout(time: 1, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
            }
        }
        stage ('Package') {
            stages {
                stage ('Build WAR file') {
                    steps {
                        configFileProvider([configFile(fileId: 'maven-settings', variable: 'MAVEN_SETTINGS')]) {
                            sh "mvn \
                                -s $MAVEN_SETTINGS \
                                -Dmaven.test.skip=true \
                                -Dcheckstyle.skip \
                                -Dnexus.url=${params.NEXUS_URL} \
                                deploy"
                        }
                    }
                }
            }
        }

               // stage ('Build Image') {
               //     steps {
               //         withCredentials([usernamePassword(credentialsId: 'nexus-credentials',
               //             usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
               //             sh '''
               //                 docker build \
               //                     --force-rm\
               //                     --compress\
               //                     -f $DOCKERFILE\
               //                     -t ${IMAGE_NAME}:latest\
               //                     . \
               //                 && docker login -u ${NEXUS_USERNAME} -p ${NEXUS_PASSWORD} ${DOCKER_REGISTRY} \
               //                 && docker tag ${IMAGE_NAME}:latest ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest \
               //                 && docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
               //             '''
               //         }
               //     }
               // }
               
        stage ('Docker Build') {
            stages {
                stage ('Build Docker Image and push to repository') {
                    steps {
                        withRegistry('${DOCKER_REGISTRY_URL}', 'nexus-credentials') {
                            step {
                                def customImage = docker.build("IMAGE_NAME:latest")
                                customImage.push()
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}