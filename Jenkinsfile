node {
    def myRepo
    stage('Checkout') {
        echo "git checkout"
        myRepo = checkout scm
    }

    def gitCommit = myRepo.GIT_COMMIT
    def shortGitCommit = "${gitCommit[0..7]}"
    def imageTag = shortGitCommit
    def dockerRepo = "miroirs"
    def imageName = "node_devops"

    stage('Image Build') {
        echo "docker image build"
        sh "docker build . -t ${dockerRepo}/${imageName}:${imageTag}"
    }
    stage('Image Push') {
        withCredentials([
            usernamePassword(
                credentialsId: 'miroirs-docker',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PWD'
            )]) {
            echo "docker login"
            sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PWD}"
            echo "docker image push"
            sh "docker push ${dockerRepo}/${imageName}:${imageTag}"
        }   
    }
    

    stage('Deploy to gitOps Repository') {
        withCredentials([
            usernamePassword(
                credentialsId: 'miroirs-git', 
                usernameVariable: 'GIT_USER', 
                passwordVariable: 'GIT_PWD')
                ]) {
            
            def gitURL = "https://github.com/questcollector/node_gitops.git"
            sh "git clone ${gitURL}"
            sh "git config --global user.name '${GIT_USER}'"

            dir("node_gitops") {
                sh "cd ./overlays/dev && kustomize edit set image ${dockerRepo}/${imageName}:${imageTag}"
                sh "git commit -am 'Publish new version ${imageTag} to dev' && git push"
            }
        }    
    }
}