
# Pipeline Best Practice

* [just-enough-pipeline](https://www.jenkins.io/blog/2021/10/26/just-enough-pipeline/)
* [CloudBees Pipeline BestPractice](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-best-practices)
* YouTube: [Scripted vs. declarative Pipelines:What is the difference?](https://www.youtube.com/watch?v=GJBlskiaRrI=)
* [Scripted vs. declarative Pipelines](https://e.printstacktrace.blog/jenkins-scripted-pipeline-vs-declarative-pipeline-the-4-practical-differences/)

# MultiBranch job and Organisation Folder setup using GitHub App token

* https://www.cloudbees.com/blog/jenkins-multibranch-pipeline-with-git-tutorial
* https://docs.cloudbees.com/docs/cloudbees-jenkins-platform/latest/github-app-auth
* https://docs.cloudbees.com/docs/cloudbees-jenkins-platform/latest/github-branch-source 

# GitHub Rate Limits

* https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#primary-rate-limit-for-unauthenticated-users

# Use Templates from a shared Library 

* https://github.com/cloudbees-oss/pipeline-home-demo/blob/master/templates/docker-java-maven-app-m-ghe/Jenkinsfile 
* https://edwin-philip.medium.com/jenkins-declarative-pipeline-as-shared-library-101091fddbc1
* https://www.jenkins.io/blog/2017/10/02/pipeline-templates-with-shared-libraries/

# About sh steps and shell scripts/steps

* When to use shell: https://google.github.io/styleguide/shellguide.html#s1.2-when-to-use-shell
* Bash settings: http://redsymbol.net/articles/unofficial-bash-strict-mode/
* Shell exit codes https://www.cyberciti.biz/faq/bash-get-exit-code-of-command/

# ParallelSteps/Stages

* https://www.jenkins.io/blog/2017/09/25/declarative-1/
* https://www.cloudbees.com/blog/parallelism-and-distributed-builds-jenkins
* https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/client-and-managed-controllers/pipeline-parallel-execution-of-tasks
* https://www.jenkins.io/blog/2019/11/22/welcome-to-the-matrix/ 
* https://www.jenkins.io/blog/2019/12/02/matrix-building-with-scripted-pipeline/
* https://medium.com/@atamarzban/dynamic-parallel-stages-in-jenkins-declarative-pipelines-ce2ee8536d63
* https://github.com/pipeline-demo-caternberg/pipeline-examples/blob/master/jobs/Jenkins-parallel-dynamic-declaractive.groovy
* https://github.com/pipeline-demo-caternberg/pipeline-examples/blob/master/jobs/Jenkinsfile-parrallel-sequential-stages.groovy

# Maven parallel Tests

* https://maven.apache.org/surefire/maven-surefire-plugin/examples/fork-options-and-parallel-execution.html
* https://www.baeldung.com/maven-junit-parallel-tests


# Parametrized Pipelines

# Parameters

* https://www.baeldung.com/ops/jenkins-parameterized-builds

## Dynamic

* https://stackoverflow.com/questions/44570163/jenkins-dynamic-declarative-pipeline-parameters

## Active Choice 

* https://www.infracloud.io/blogs/render-jenkins-build-parameters-dynamically/#:~:text=Go%20to%20Jenkins%20Home%2C%20select,Application%20Tiers%20as%20a%20Dropdown. 