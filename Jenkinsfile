pipeline {

    agent any

    tools {
        maven 'maven-3.5.4'
        jdk 'jdk8'
    }

    stages {
        stage ('Package') {
            parallel {
                stage ('Build WAR file') {
                    steps {
                        sh 'mvn -Dmaven.test.failure.ignore=true clean install' 
                    }
                }
            }
        }

        stage ('Code analysis') {
            parallel {
                stage ('SonarQube code analysis') {
                    steps {
                        sh 'mvn sonar:sonar \
                            -Dsonar.host.url=http://sonarqube-testp.192.168.99.100.nip.io \
                            -Dsonar.login=b2c49d6ef4978a6f9bd46b030ca9000379b1f682'
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