library identifier: 'ci-shared-library@main', retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://github.com/cb-ci-templates/ci-shared-library.git'])


// Building the data object
def configYaml = """---
app : 'App Hello World'
k8_agent_yaml : 'podTemplate-curl.yaml'
param_greetings : 'Greetings to the rest of the World!'
default_key1: 'default_value1'
scanCheckmarx: true
dynamicStages:
  UnitTests: 123 Main Street
  IntegrationTests: New York
  SmokeTests: NY
  RegressionTests: 10001
"""
//Create a pipelineParams Map for the Pipeline template below
Map pipelineParams = readYaml text: "${configYaml}"
println pipelineParams

/*
dynamicStages test list to generate dynamicStages
Need to be configured by parameters or properties
 */
//def dynamicStages = ["UnitTests", "IntegrationTests", "SmokeTests","RegressionTests","AccessibilityTests"]

//###### START PIPELINE TEMPLATE###########
//We could call the Pipeline template from a shared library method
//However, the more templates we add to the library the bigger the size of the shared library
//pipelineHelloWorld (pipelineParams)

//So we can use the template also directly from here instead calling a shared library function
pipeline {
    agent {
        kubernetes {
            yaml libraryResource("podtemplates/${pipelineParams.k8_agent_yaml}")
        }
    }
    parameters {
        string(name: 'greeting', defaultValue: "${pipelineParams.param_greetings}",
                description: 'How should I greet the world?')
    }
    stages {
        stage("Init") {
            steps {
                //Init from yaml. It uses the `readYaml` step which can not use defaults
                //initFromYaml "./ci-config.yaml"

                validate('ci-config.properties',pipelineParams,params)
                //init from properties with defaults  (here "default_key1" f.e)
                init('ci-config.properties', pipelineParams)

                echo """###### SAMPLE OUTPUT OF VARS#####
                Pipeline parameter: ${params.greeting}
                Pipeline Template parameter: ${pipelineParams.app}
                default_key1 ${env.default_key1}
                branch_key1 ${env.key1}
                property DEPLOY from default config:${env.deploy}
                default dynamicStages from default config:${env.dynamicStages}
                ###### END SAMPLE OUTPUT OF VARS#####
                """

            }
        }
        stage('Build') {
            steps {
                echo "here we execute the build"
            }
        }
        stage('Test') {
            /*TODO: dynamic parallel stages are possible, however, they lead to more complexity and should be avoided when possible
              TODO: Verify: Instead of using dynamic parallel stages Maven parallel test  might be a better choice
              https://maven.apache.org/surefire/maven-surefire-plugin/examples/fork-options-and-parallel-execution.html
              https://www.baeldung.com/maven-junit-parallel-tests
              TBD: What exactly  are the test types?
              * Junit Tests?
              * UI Tests (Selenium f.e.)
              *Cross Platform/Browser tests? -> Matrix parallel stages might be an option
              * ???
              Depending on the test types the parallel structure and approach might be different
              def dynamicStages = ["UnitTests", "IntegrationTests", "SmokeTests","RegressionTests","AccessibilityTests"]
               steps {
                // Create a parallel block for dynamic stages, not sure yet if dynamic is  required
                parallelTestStages dynamicStages
            }

             */
            steps {
               // sh "echo UnitTests/ maybe not required when Unit tests are executed in the build stage"
                parallelTestStages "${env.dynamicStages}"
            }
        }
        stage('Quality Gate') {
            //Skip the stage on other branches, execute just on "main"
            //TODO: This is just an example on how to skip stages, we need to decide if scans should be done on each branch or not
            when {
                branch 'main'
            }
            /*
            We know the quality gates so we can use static parallel structure
             */
            parallel {
                stage("NexusIQ") {
                    steps {
                        sh "echo results NexusIQ"
                    }
                }
                stage("Sonar") {

                    steps {
                        sh "echo scan Sonar"
                    }
                }
                stage("Checkmarx") {
                    //Example for an optional QA stage
                    when {
                        environment name: 'scanCheckmarx', value: 'true'
                    }
                    steps {
                        sh "echo scan Checkmarx"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo """Here deploy the artifacts to integration test environment"""
                evaluate("${env.deploy} ()")
            }
        }
        stage('PostDeployTest') {
            parallel {
                stage("SeleniumTests") {
                    stages {
                        stage("test") {
                            steps {
                                sh "echo UnitTests"
                            }
                        }
                    }
                    post {
                        /**
                         see all post options https://www.jenkins.io/doc/book/pipeline/syntax/#post
                         */
                        always {
                            echo "do something on success"
                        }
                        success {
                            echo "do something on success"
                        }
                    }
                }
                stage("APITest") {
                    stages {
                        stage("test") {
                            steps {
                                sh "echo IntegrationTests"
                            }
                        }
                    }
                    post {
                        /**
                         see all post options https://www.jenkins.io/doc/book/pipeline/syntax/#post
                         */
                        always {
                            echo "do something on success"
                        }
                        success {
                            echo "do something on success"
                        }
                    }
                }
                stage("CocumberTest") {
                    stages {
                        stage("test") {
                            steps {
                                sh "echo SmokeTests"
                            }
                        }
                    }
                    post {
                        /**
                         see all post options https://www.jenkins.io/doc/book/pipeline/syntax/#post
                         */
                        always {
                            echo "do something on success"
                        }
                        success {
                            echo "do something on success"
                        }
                    }
                }
                stage("ToscaTest") {
                    stages {
                        stage("test") {
                            steps {
                                sh "echo AccessibilityTests"
                            }
                        }
                    }
                    post {
                        /**
                         see all post options https://www.jenkins.io/doc/book/pipeline/syntax/#post
                         */
                        always {
                            echo "do something on success"
                        }
                        success {
                            echo "do something on success"
                        }
                    }
                }
            }
        }
    }
    post {
        /**
         see all post options https://www.jenkins.io/doc/book/pipeline/syntax/#post
         */
        always {
            echo "do something on success"
        }
        success {
            echo "do something on success"
        }
    }
}

