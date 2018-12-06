pipeline {

    agent any

    environment {
        SONAR_HOST              = 'http://sonarqube-testp.192.168.99.100.nip.io'
        SONAR_LOGIN             = '8d30ad7095aa9e5026058726585a7b2680313c3f'
    }

    tools {
        maven 'maven-3.5.4'
        jdk 'jdk8'
    }

    stages {
        stage ('Code build') {
            parallel {
                stage ('Build WAR file') {
                    steps {
                        sh 'mvn -Dmaven.test.failure.ignore=true clean compile' 
                    }
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
                        timeout(time: 1, unit: 'HOURS') {
                            waitForQualityGate abortPipeline: true
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