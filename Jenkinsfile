node {
    stage('Image Build') {
        sh "docker build . -t miroirs/node_devops:${imageTag}"
    }

    stage('Image Push') {
        sh "docker push miroirs/node_devops:${imageTag}"
    }

    stage('Deploy to gitOps Repository') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'miroirs-git', 
                    usernameVariable: 'GIT_USER', 
                    passwordVariable: 'GIT_PWD')
                    ]) {
                sh ""
            }
        }
    }
}