pipeline {

    agent any

    parameters {
        string( name: 'nexus_url', 
                defaultValue: 'http://nexus3:8081', 
                description: 'URL of the Nexus server')
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
                            sh '''
                                mvn \
                                -s $MAVEN_SETTINGS \
                                -Dmaven.test.skip=true \
                                -Dcheckstyle.skip \
                                -Drepository.nexus=$params.nexus_url \
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