pipeline {

    agent any

    tools {
        maven 'maven-3.5.4'
        jdk 'jdk8'
    }

    stages {

/*
        stage ('Test') {
        }
*/
        stage ('Code analysis') {
            stages {
                stage ('SonarQube - Code analysis') {
                    steps {
                        sh 'mvn sonar:sonar \
                            -Dsonar.host.url=http://sonarqube-testp.192.168.99.100.nip.io \
                            -Dsonar.login=b2c49d6ef4978a6f9bd46b030ca9000379b1f682'
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

    stage ('Package') {
            stages {
                stage ('Build WAR file') {
                    steps {
                        sh 'mvn -Dmaven.test.failure.ignore=true clean install' 
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