library identifier: 'ci-shared-library@main', retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://github.com/cb-ci-templates/ci-shared-library.git'])


// Building the data object
def configYaml = """---
app : 'App Hello World'
k8_agent_yaml : 'podTemplate-curl.yaml'
param_greetings : 'Greetings to the rest of the World!'
"""
//Create a pipelineParams Map for the Pipeline template
Map pipelineParams = readYaml text: "${configYaml}"
println pipelineParams

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

                //So better init from properties with defaults  (here "default_key1" f.e)
                defineProps('ci-config.properties', [default_key1: 'default_value1'])

                echo "###### SAMPLE OUTPUT OF VARS#####"
                echo "Greetings: ${params.greeting}"
                echo "${pipelineParams.app}"
                sh "echo default_key1 ${env.default_key1}"
                sh "echo branch_key1 ${env.key1}"
                echo "###### END SAMPLE OUTPUT OF VARS#####"

            }
        }
        stage('Build') {
            steps {
                echo "here we execute the build"
            }
        }
        stage('Test') {
            steps {
                echo """Here we call our tests  (unit test, component test)
                        Optional, test can be executed in parallel using parallel stages
                """
            }
        }
        stage('Quality Gate') {
            //Skip the stage on other branches, execute just on "main"
            when {
                branch 'main'
            }
            steps {
                echo """Here scan the code (NexusIQ, Sonar etc
                        Optional, Scans can be executed in parallel using parallel stages
                """
            }
        }
        stage('Deploy') {
            steps {
                echo """Here deploy the artifacts to integration test environment"""
            }
        }
        stage('Integration Test') {
            steps {
                echo """Here run integration test and acceptance test
                        can be done in parallel
                    """
            }
        }
    }
}

