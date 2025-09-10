#!/usr/bin.env groovy

pipeline {   
    agent any
    stages {
        stage("test") {
            steps {
                script {
                    echo "Testing the application..."

                }
            }
        }
        stage("build") {
            steps {
                script {
                    echo "Building the application..."
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    def dockerCmd = 'docker run -p 3080:3080 -d tracyhsu57/my-app:1.0'
                    sshagent(['ec2-server-key']) {
                        //suppress the pop-up: -o StrictKeyChecking=no
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.99.128.85 ${dockerCmd}"
                    }
                }
            }
        }               
    }
} 
