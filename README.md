# About 
This repo contains CloudBees CI Pipeline Templates.
This repository can be referenced from  

* [Marker files](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#custom-pac-scripts) in 
  * [MultiBranchSource Pipelines](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_multibranch_pipeline_projects)
  * [Pipeline Organisation Folders](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_organization_folders)
* [Pipeline Template catalogs](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipeline-templates-user-guide/)

# Structure 
The repository structure follows the recommended repository design for Pipeline Template catalogs, however, the Jenkinsfiles can be referenced as well from MultiBranch and Organisation Folder Pipelines (Custom Marker).
Pipeline Templates are stored under a `/templates` folder in your source code repository, and each Pipeline Template is defined as a `subfolder` containing two files:

* Jenkinsfile: A standard Pipeline `Jenkinsfile`, which supports either Declarative Pipeline syntax or Groovy scripting.

* template.yaml: A YAML file containing the template’s parameters. This file is just required when using Pipeline Template Catalogs, not required when referencing from Custom Marker files
  


```
├── README.md
├── catalog.yaml #Pipeline Template Catalog descriptor
└── templates
    ├── helloWorld  #tenplate folder
    │   ├── Jenkinsfile # Jenkins file used as temlate
    │   │── README.md    
    │   └── template.yaml #Pipeline Template Catalog descriptor
    ├── ....  # more template folders 
```

![Diagram](images/CI Diagramms-CustomMarkerFiles.drawio.svg)

# How to use

## Pre-requirements:

* Set up credentials for GitHub
    * GH User and SSH key (Type SSH user and private key)
    * GH Access token (Type secret text)

# Docs & Videos

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
