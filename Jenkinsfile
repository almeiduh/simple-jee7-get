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
                        timeout(time: 1, unit: 'MINUTES') {
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