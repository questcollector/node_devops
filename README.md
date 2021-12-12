# node_devops
## DevOps tools with
  - node.js
    <br> express web service
  - github
    <br> devops/gitops repository
  - jenkins
    <br> CI tool
  - docker
    <br> build an application image, then push it to docker hub
## reference
  - https://kangwoo.kr/2019/12/18/gitops-and-kubernetes/
    <br> devops/gitops 구성
  - https://kangwoo.kr/2019/12/18/gitops-and-kubernetes/
    <br> node app image build
  - https://www.jenkins.io/doc/book/installing/docker/
    <br> jenkins install - docker
## 1. dockerize node app
  - node app 구성
    <br> https://github.com/questcollector/node_devops
  - Dockerfile 파일 구성
    <br> https://github.com/questcollector/node_devops/blob/master/Dockerfile
## 2. Jenkins 구성 (docker 기반)
  - docker network 생성 (작업 디렉토리 jenkins)
  ``` sh
  mkdir jenkins
  cd jenkins
  docker network create jenkins
  ```
  - jenkins Dockerfile 구성
  ``` Dockerfile
  # jenkins/Dockerfile
  FROM jenkins/jenkins:latest AS docker
  USER root
  RUN apt-get update && apt-get install -y lsb-release
  RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
  RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  RUN apt-get update && apt-get install -y docker-ce-cli

  # kustomize install
  FROM docker AS kustomize
  WORKDIR /usr/bin/
  RUN curl --silent --location --remote-name https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.4.1/kustomize_v4.4.1_linux_arm64.tar.gz
  RUN tar -xzf kustomize_v4.4.1_linux_arm64.tar.gz

  # blueocean은 필요시 추가 설치
  FROM kustomize AS jenkins
  USER jenkins
  RUN jenkins-plugin-cli --plugins "docker-workflow:1.26"
  ```
  - docker image build
  ``` sh
  docker build -t jenkins-server:1.0 .
  ```
  - docker compose 구성
  ``` yaml
  # jenkins/docker-compose.yml
  version: '3'
  services:
    jenkins-blueocean:
      depends_on:
        - jenkins-docker
      image: jenkins-server:1.0
      container_name: jenkins-server
      privileged: true
      environment:
        DOCKER_HOST: tcp://docker:2376
        DOCKER_CERT_PATH: /certs/client
        DOCKER_TLS_VERIFY: 1
      networks:
        jenkins:
      volumes:
        - "jenkins-data:/var/jenkins_home"
        - "jenkins-docker-certs:/certs/client:ro"
      ports:
        - "8080:8080"
        - "50000:50000"
    jenkins-docker:
      image: docker:dind
      container_name: jenkins-docker
      privileged: true
      command: --storage-driver=overlay2
      environment:
        DOCKER_TLS_CERDIR: /certs
      networks:
        jenkins:
          aliases:
            - docker
      volumes:
        - "jenkins-docker-certs:/certs/client"
        - "jenkins-data:/var/jenkins_home"
      ports:
        - "2376:2376"

  networks:
    jenkins:
      external: true
      name: jenkins
  volumes:
    jenkins-data:
      external: true
    jenkins-docker-certs:
      external: true
  ```
  - jenkins 실행
  ``` sh
  docker-compose -d up
  ```
  - jenkins setup
    <br> https://www.jenkins.io/doc/book/installing/docker/#setup-wizard
  - jenkins credential 구성
    - github credential
      <br> to get pipeline script(Jenkinsfile) from git  
    - docker hub credential (miroirs-docker)
      <br> for image push
    - github token(Github-token)
      <br> to push to gitOps repo
  - jenkins 로컬 서버 외부에 노출하기
    <br> https://velog.io/@kya754/ngrok-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0
    - 백그라운드 실행
    ``` sh
    nohup ngrok http 8080 &
    ```
  - jenkins github webhook 구성
    <br> https://nirsa.tistory.com/301
## 3. Pipeline / Jenkinsfile 구성
  - Jenkinsfile
    <br> https://github.com/questcollector/node_devops/blob/master/Jenkinsfile
  - pipeline
    <br> https://cwal.tistory.com/24
