pipeline {

    agent any

    environment {
        SONAR_HOST              = 'http://sonarqube:9000'
        SONAR_LOGIN             = '9d9603ea54bb22b7e3b7e47a78c2d7654d734aec'
    }

    tools {
        maven 'maven-3.5.4'
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
                                mvn sonar:sonar \
                                -Dsonar.host.url=${SONAR_HOST} \
                                -Dsonar.login=${SONAR_LOGIN}
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
                            sh '''
                                mvn \
                                    -s $MAVEN_SETTINGS \
                                    -Dmaven.test.skip=true \
                                    -Dcheckstyle.skip \
                                    -Drepository.nexus=${NEXUS_SERVER} \
                                    deploy
                            '''
                        }
                    }
                }

                stage ('Build Image') {
                    steps {

                        withCredentials([usernamePassword(credentialsId: 'nexus',
                            usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
                            sh '''
                                docker build \
                                    --force-rm\
                                    --compress\
                                    -f $DOCKERFILE\
                                    -t ${IMAGE_NAME}:latest\
                                    . \
                                && echo ${NEXUS_PASSWORD} \
                                    | docker login -u ${NEXUS_USERNAME} --password-stdin ${DOCKER_REGISTRY} \
                                && docker tag ${IMAGE_NAME}:latest ${DOCKER_REGISTRY}/${TARGET_IMAGE}:latest \
                                && docker push ${DOCKER_REGISTRY}/${TARGET_IMAGE}:latest
                            '''

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