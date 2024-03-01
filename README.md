# About 
This repo contains CloudBees CI Pipeline Templates.
This repository can be referenced from  

* [Marker files](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#custom-pac-scripts) in 
  * [MultiBranchSource Pipelines](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_multibranch_pipeline_projects)
  * [Pipeline Organisation Folders](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipelines/pipeline-as-code#_organization_folders)
* [Pipeline Template catalogs](https://docs.cloudbees.com/docs/cloudbees-ci/latest/pipeline-templates-user-guide/)

# Structure 
The structure follows the recomened repository design for Pipeline Template catalogs
```
├── README.md
├── catalog.yaml
└── templates
    ├── helloWorld
    │   ├── Jenkinsfile
    │   │── README.md    
    │   └── template.yaml
    ├── helloWorldGolang
    │   ├── Jenkinsfile
    │   │── README.md
    │   └── template.yaml
    ├── mavenSimplePipeline
    │   ├── Jenkinsfile
    │   ├── README.md
    │   └── template.yaml
    └── parametrizedPipeline
        ├── Jenkinsfile
        │── README.md
        └── template.yaml
```

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

GitHub App Authentication
* [Using GitHub App authentication](https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth)

# MultiBranch Pipeline Branch Protection

Some teams might have the requirements in MultiBranch Pipelines that not all branches should be scanned.

* use filter branches
* setup branch protection in GitHub


# Setup GitHub Branch Protection
Certainly, for GitHub, you can follow these steps to give teams push/pull permissions for dedicated branches:

## Create a Team:

* Navigate to your GitHub repository.
* Click on the "Settings" tab.
* Select "Teams" from the left sidebar.
* Create a team and add the relevant members to it.
  * [Protect Branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches):
    * Go back to the "Settings" tab of your repository.
    * Select "Branches" in the left sidebar.
    * Choose the branch you want to protect (e.g., main or master).
    * Enable "Require pull request reviews before merging" and other desired settings.
    * Click on "Save changes."
  * [Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule):
    * Still in the "Branches" settings, click on "Add rule."
    * Define the rules for the branch protection, such as:
    * Require pull request reviews.
    * Disallow force pushes.
    * Restrict who can push to the branch.
  * [Team Permissions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-teams-and-people-with-access-to-your-repository):
    * Go back to the "Settings" tab.
    * Click on "Branches" in the left sidebar.
    * Scroll down to the "Protected branches" section and click on the branch you want to manage.
    * Under "Who can push to this branch," add the team you created.
* This setup ensures that only team members with the required permissions (as defined in the team settings and branch protection rules) can push directly to the protected branch. Others will need to fork the repository, create a feature branch, and open a pull request to propose changes.
* Always remember to adjust the settings based on your specific requirements, and the exact steps might change slightly if GitHub updates its interface or features in the future.
