pipeline {

    agent any

    tools {
        maven 'maven-3.5.4'
        jdk 'jdk8'
    }

    stages {
        stage ('Quality') {
            stages {
                stage("SonarQube analysis") {
                    steps {
                        withSonarQubeEnv('SonarQube Server') {
                            sh '''
                                mvn sonar:sonar \
                                    -Dsonar.host.url=http://sonarqube-testp.192.168.99.100.nip.io \
                                    -Dsonar.login=b2c49d6ef4978a6f9bd46b030ca9000379b1f682
                            '''
                        }
                    }
                }
                stage("Quality Gate") {
                    steps {
                        timeout(time: 1, unit: 'HOURS') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
            }
        }
        stage ('Package') {
            parallel {
                stage ('Build WAR file') {
                    steps {
                        sh 'mvn -Dmaven.test.failure.ignore=true clean install' 
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