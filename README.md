# About 
This repository contains CloudBees CI Pipeline Templates.
It can be referenced from:

* [Marker files](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#custom-pac-scripts) in 
  * [MultiBranchSource Pipelines](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_multibranch_pipeline_projects)
  * [Pipeline Organisation Folders](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_organization_folders)
* [Pipeline Template catalogs](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipeline-templates-user-guide/)

# Goal
The goal is to serve opinionated Pipeline templates with proper CI stages and phases as shown below

![CI-Pipeline.png](images/CI-Pipeline-1.png)

# Structure 
The repository structure follows the recommended repository design for Pipeline Template catalogs, however, the Jenkinsfiles can be referenced as well from MultiBranch and Organisation Folder Pipelines (Custom Marker).
Pipeline Templates are stored under the `/templates` folder, and each Pipeline Template is defined as a `subfolder` containing two files:

* Jenkinsfile: A standard Pipeline `Jenkinsfile`, which supports either Declarative Pipeline syntax or Groovy scripting.
* template.yaml: A YAML file containing the template’s parameters. This file is just required when using Pipeline Template Catalogs, not required when referencing from Custom Marker files

```
├── README.md
├── catalog.yaml #Pipeline Template Catalog descriptor
└── templates  # Pipeline Tenplate Catalog
   ├── helloWorldSimple  #tenplate folder
   │   ├── Jenkinsfile # Jenkins file used as temlate
   │   │── README.md    
   │   └── template.yaml #Pipeline Template descriptor
   ├── ....  # more template folders 

```
# Component diagram
![CI-Component-diagram.png](images/CI-Component-diagram.png)

TODO: description and design

# Custom marker files and Pipeline templates

![Diagram](images/CI-Diagramms-CustomMarkerFiles.svg)

[Custom marker files](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#custom-pac-scripts) in the context of CloudBees CI are special files that you can place in a repository to control the behavior of your build. 
They are typically named and placed according to certain conventions recognized by your build system or CI/CD pipeline, and they can signal to CloudBees CI or Jenkins to perform specific actions or apply certain configurations.
For example, you might use a custom marker file to:

* Ignore certain job or pipeline runs: Placing a file like `.ci-ignore` might tell Jenkins to skip the build for a commit that includes this file.
* Control build parameters: A file such as `build.properties`or `build-properties.yaml` might contain key-value pairs that are injected as parameters into the build process.

Templates, on the other hand, are predefined configurations or job definitions that can be reused across multiple projects or repos. Templates can help enforce consistency and reduce duplication of pipeline code, making it easier to manage Jenkins jobs or CloudBees CI pipelines at scale.

To use templates with custom marker files, you would:

* Set Up Template Catalogs: Define a catalog of templates in your CloudBees CI system. This involves creating the pipeline configurations that will be used as templates, which can be written in Jenkinsfile or another supported format.
* Centralize Templates Management: Store these templates in a source control management system that is accessible by your CloudBees CI instance. For instance, a Git repository dedicated to CI/CD templates can serve this purpose.
* Integrate Marker Files with Templates: Configure your CloudBees CI or Jenkins instance to recognize custom marker files and map them to the corresponding template. This might require additional plugin support or scripting within your Jenkins configuration.
* Create and Commit Custom Marker Files: Develop custom marker files that contain the necessary instructions or metadata to select and apply a template. When you commit these files to your repository, your CI/CD system should detect the marker file and execute the build using the template that matches the instructions.
* Use a Templating Engine (optional): For more dynamic use of templates, you could use a templating engine that replaces placeholders within your template with values derived from the custom marker files.

For instance, you might have a marker file .build-template containing:

* TEMPLATE_NAME=java-build-pipeline
* ADDITIONAL_FLAGS=-DskipTests

* When the build runs, CloudBees CI or Jenkins would recognize the marker file, apply the java-build-pipeline template, and pass any additional flags (in this case, -DskipTests) to the build process.

Please note that the exact steps and capabilities may vary based on the specific plugins and configuration of your CloudBees CI or Jenkins instance.
Be sure to consult the official CloudBees documentation or a knowledgeable colleague for more details relevant to your setup.



## Pre-requirements:

* Set up credentials for GitHub
    * GH User and SSH key (Type SSH user and private key)
    * GH Access token (Type secret text). See  [Using GitHub App authentication](https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth)


##  Branch Suppress Strategies

```
strategy:
  namedBranchesDifferent:
    defaultProperties:
    - suppressAutomaticTriggering:
        triggeredBranchesRegex: ^.*$
        strategy: INDEXING
    namedExceptions:
    - named:
        name: PR-\d+
        props:
        - suppressAutomaticTriggering:
            triggeredBranchesRegex: ''
            strategy: NONE
```

# Docs & Videos

Pipeline Best Practice
* [just-enough-pipeline](https://www.jenkins.io/blog/2021/10/26/just-enough-pipeline/)
* [CloudBees Pipeline BestPractice](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-best-practices)
* YouTube: [Scripted vs. declarative Pipelines: What is the difference?](https://www.youtube.com/watch?v=GJBlskiaRrI=)
* [Scripted vs. declarative Pipelines](https://e.printstacktrace.blog/jenkins-scripted-pipeline-vs-declarative-pipeline-the-4-practical-differences/)

MultiBranchSource Pipelines
* YouTube: [How to Create a GitHub Branch Source Multibranch Pipeline in CloudBees CI](https://www.youtube.com/watch?v=ZWwmh4gqia4)
* [MultiBranchSource Pipelines](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_multibranch_pipeline_projects)

Pipeline Template Catalogs
* YouTube: [Introduction to Pipeline Template Catalogs with CloudBees CI](https://www.youtube.com/watch?v=pPwI_kTSCmA)
* [Pipeline Template catalogs](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipeline-templates-user-guide/)

Pipeline Organisation Folders
* YouTube: [How to Create a GitHub Organization in CloudBees CI](https://www.youtube.com/watch?v=w5YupbQ1vHI)
* [Pipeline Organisation Folders](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_organization_folders)

MarkerFiles
* [Marker files](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#custom-pac-scripts)
* [ensuring-corporate-standards-pipelines-custom-marker-files](https://www.cloudbees.com/blog/ensuring-corporate-standards-pipelines-custom-marker-files)

GitHub App Authentication
* [Using GitHub App authentication](https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth)
