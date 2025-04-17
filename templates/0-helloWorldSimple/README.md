## Overview

This directory contains a Jenkins pipeline template that utilizes a shared library and runs on a Kubernetes agent. 
The pipeline executes a series of custom `helloworld`  steps inside a custom container.

## Prerequisites

Before running this pipeline, ensure you have the following:

- Jenkins with Kubernetes plugin installed
- A Kubernetes cluster configured as an agent for Jenkins
- The following Jenkins plugins installed:
    - **Pipeline: Shared Groovy Libraries**
    - **Kubernetes Plugin**
    - **Git Plugin**

## Setting Up the Shared Library

This pipeline uses a shared library stored in a Git repository. The library is dynamically loaded using an environment variable `SHARED_LIB_TAG`, which should be set in Jenkins Folder environment properties.

Example configuration:

```groovy
// Ensure the shared library tag is injected via Jenkins Folder properties
env.SHARED_LIB_TAG="main"

// Load the shared library
library identifier: "ci-shared-library@${env.SHARED_LIB_TAG}", retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://github.com/cb-ci-templates/ci-shared-library.git'])
```

## Agent Configuration

This pipeline runs on a Kubernetes agent using a custom pod template. The YAML configuration for the pod template is stored as a resource in the shared library (`podtemplates/podTemplate-curl.yaml`).

Agent assignment in the pipeline:

```groovy
pipeline {
    agent {
        kubernetes {
            defaultContainer "custom-agent"
            yaml pod
        }
    }
```

- The `defaultContainer` is set to `custom-agent`.
- The `yaml` variable loads the pod template YAML from the shared library.

## Pipeline Stages

The pipeline consists of the following stages:

### **1. Hello Stage**

- Prints the hostname of the agent.
- Calls a `helloWorld` function with `firstname` and `lastname`.
- `firstname` and `lastname` are desclared in `template.yaml`

### **2. Hello2 Stage**

- Repeats the steps in the Hello stage.

Example stage execution:

```groovy
stage('Hello') {
    steps {
        sh 'hostname'
        helloWorld "${firstname}"
        helloWorld "${lastname}"
    }
}
```

## Running the Pipeline

To execute this pipeline:

1. Ensure Jenkins is configured with access to the Kubernetes cluster.
2. Set the `SHARED_LIB_TAG` environment variable in the Jenkins Folder properties.
3. Run the pipeline from Jenkins UI or via a Jenkinsfile.

## Troubleshooting

- If the shared library fails to load, verify the repository URL and the `SHARED_LIB_TAG` value.
- If the Kubernetes agent does not start, check the pod template YAML and ensure the Kubernetes plugin is installed and configured correctly.

## Contributing

Feel free to submit issues or pull requests to improve this pipeline setup.

## License

This project is licensed under the MIT License.


