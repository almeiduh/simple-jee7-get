pipeline {

    agent any

    environment {
        SONAR_HOST              = 'http://localhost:9000'
        SONAR_LOGIN             = 'ca566a6e0dff3d7eaaffa93253c0dbd0691a5143'
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

    post {
        always {
            deleteDir()
        }
    }
}