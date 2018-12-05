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
    }

    post {
        always {
            deleteDir()
        }
    }
}