#!/usr/bin/env groovy

@Library('jenkins-shared-library@master')_

// library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
//     [$class: 'GitSCMSource',
//     remote: 'https://github.com/hsuhana/jenkins-shared-library-ec2.git',
//     credentialsID: 'github-repo'
//     ]
// )

pipeline {
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage('build app') {
            steps {
                echo 'building application jar...'
                buildJar()
                sh 'mvn clean package'
            }
        }
        stage('build image') {
            steps {
                script {
                    echo 'building the docker image...'
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        } 
        stage("deploy") {
            steps {
                script {
                    echo 'deploying docker image to EC2...'

                    def shellCmd = "bash ./server-cmds.sh tracyhsu57/my-app:${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@3.99.128.85"
                    
                    sshagent(['ec2-server-key']){
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }


                    // def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    // def ec2Instance = "ec2-user@18.184.54.160"

                    // sshagent(['ec2-server-key']) {
                    //     sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                    //     sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                    //     sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    // }
                }
            }               
        }
        stage('commit version update'){
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                        sh 'git remote set-url origin https://$USER:$PASS@github.com/hsuhana/maven-app-with-EC2.git'
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:jenkins-jobs'
                    }
                }
            }
        }
    }
}
