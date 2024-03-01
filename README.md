This repo contains CloudBees CI Pipeline Templates.


Directories
* templates: contains sample [Pipeline Template catalogs](https://docs.cloudbees.com/docs/admin-resources/latest/pipeline-templates-user-guide/)


if you try to run the Jenkinsfiles standalone, you have to fix the path to the yamlFile of some `jobs/Jenkinsfile-*` in this area to your belongings
```
agent {
    kubernetes {
        yamlFile 'yaml/podTemplate.yml'
    }
}
```



## Pre-requirerments: Set up credentials for GitHub

Setup the following credentials:  (used by some pipelines)

* githubuserssh= GH User and SSH key (Type SSH user and private key)
* githubaccesstoken= GH Access token (Type secret text)

## A simple-docker-kaniko-pipeline-example
A simple Dockerfile to build with kaniko
see https://docs.cloudbees.com/docs/cloudbees-core/latest/cloud-admin-guide/using-kaniko#_create_a_new_kubernetes_secret   for further details


# Git Hub Branch Protection

see: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule

Certainly, for GitHub, you can follow these steps to give teams push/pull permissions for dedicated branches:

## Create a Team:

* Navigate to your GitHub repository.
* Click on the "Settings" tab.
* Select "Teams" from the left sidebar.
* Create a team and add the relevant members to it.
  * Protect Branches:
   * Go back to the "Settings" tab of your repository.
   * Select "Branches" in the left sidebar.
   * Choose the branch you want to protect (e.g., main or master).
   * Enable "Require pull request reviews before merging" and other desired settings.
   * Click on "Save changes."
 * Branch Protection Rules:
  * Still in the "Branches" settings, click on "Add rule."
  * Define the rules for the branch protection, such as:
  * Require pull request reviews.
  * Disallow force pushes.
* Restrict who can push to the branch.
 * Team Permissions:
  * Go back to the "Settings" tab.
  * Click on "Branches" in the left sidebar.
  * Scroll down to the "Protected branches" section and click on the branch you want to manage.
  * Under "Who can push to this branch," add the team you created.
* This setup ensures that only team members with the required permissions (as defined in the team settings and branch protection rules) can push directly to the protected branch. Others will need to fork the repository, create a feature branch, and open a pull request to propose changes.

Always remember to adjust the settings based on your specific requirements, and the exact steps might change slightly if GitHub updates its interface or features in the future.
