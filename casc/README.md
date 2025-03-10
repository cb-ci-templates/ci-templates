# Setup

The following instruction describes how to setup a pre-provisioned Controller by a CasC [controller-ci-templates](controller/controller-ci-templates) bundle which includes: 
* all required plugins 
* all required Credentials 
* a pre-configured MultiBranch and GitHub Organisation Job setup, ready to execute
  * referencing this Pipeline template [Jenkinsfile](../templates/mavenMultiBranch/Jenkinsfile) 
  * referencing a spring-boot sample application repo https://github.com/cb-ci-templates/sample-app-spring-boot-maven 


# Pre-requirements:

* A CloudBees CI Operations Center on modern platform (Kubernetes, setup managed by YOU) 
* Credentials: (setup managed by CasC, [credentials.yaml](controller/controller-ci-templates/credentials.yaml))
  * Dockerconfig Credential
    * description: "credential to pull/push to dockerhub"
    * type: "Secret text"
    * credentialId: dockerconfig
    * content: 
      ```
      {
        "auths": {
          "https://index.docker.io/v1/": {
            "username": "<YOUR_USER>",
            "password": "<YOUR_PASSWORD>",
            "email": "<YOUR_EMAIL>",
            "auth": "<YOUR_BASE64_USER:PASSWORD>"
          }
        }
      }
      ```
  * GitHubApp Credentials
    * description: "GHApp credentials to scan repositories and to clone"
    * type: "GitHub App"
    * credentialId: ci-template-gh-app
    * See:  [Using GitHub App authentication](https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth)
* Plugins: (setup managed by CasC, [plugins.yaml](controller/controller-ci-templates/plugins.yaml))
  * Plugins referenced in the sample template
    * https://plugins.jenkins.io/pipeline-maven
    * https://www.jenkins.io/doc/pipeline/steps/junit
    * https://plugins.jenkins.io/build-discarder  (will be removed soon)
    * https://plugins.jenkins.io/pipeline-utility-steps (tier 3 plugin)
    * These Plugins are referenced from
      * https://github.com/cb-ci-templates/ci-templates/blob/main/templates/mavenMultiBranch/Jenkinsfile
      * https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/pipelineMaven.groovy



# Steps

* Fork the following repositories in your own GitHub organisation:
  * https://github.com/cb-ci-templates/ci-templates
  * https://github.com/cb-ci-templates/ci-shared-library
  * https://github.com/cb-ci-templates/sample-app-spring-boot-maven
* Clone the https://github.com/cb-ci-templates/ci-templates to your terminal and follow the instructions below

## Update Shared Library references

Update the reference to the shared library in the template [Jenkinsfile](../templates/mavenMultiBranch/Jenkinsfile)
Currently, there is a reference to the shared library hosted in thi GitHub Organisation.
Since you cloned the Shared Library to your organisation, you might want to update the repository URL

From
```
env.SHAREDLIB_GIT_ORG="cb-ci-templates" //"cb-ci-templates"
```
To
```
env.SHAREDLIB_GIT_ORG="<YOUR_GITHUB_ORGANISATON>" //"cb-ci-templates"
```

Then, push your updates to git

If you don`t do it, the template references still to the original Library (Which is ok for testing/demo purpose)

## Set environment

* rename `set-env.sh.template`

> cp set-env.sh.template set-env.sh

* set your custom values, see all the comments `CHANGE ME` in `set-env.sh`

## Create Credentials

Two credentials are required for:

* GitHub App Authentication [Using GitHub App authentication](https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth)
* Docker reqistry credentials to push 


Notes:

* This CasC setup reads credentials in CasC from K8s secret. However, In production, external secret managers are strongly recommended (aws secret manager, vault etc)

* rename `cbci-secrets.yaml.template`

> cp cbci-secrets.yaml.template  cbci-secrets.yaml

* Update `cbci-secrets.yaml` with your secrets

```
gitHubAppId: "YOUR_GH_APP_ID"
gitHubAppPrivateKey: |
    -----BEGIN PRIVATE KEY-----
    YOUR_GH_APP_KEY
    -----END PRIVATE KEY-----
dockerConfigJson: |
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "YOUR_USER",
          "password": "YOUR_PASSWORD",
          "email": "user@myexample.org",
          "auth": "YOUR_USER:YOUR_PASSWORD(BASE64)"
        }
      }
    }
```

* create the required credentials as K8s secrets
 * NOTE: This requires kubectl to access your c luster with the right permissions

> ./00-createCredentialSecrets.sh

# Create a Controller from Controller CasC bundle

## Install CasC plugins on CjoC

* Install the following plugins on CjoC
  ```
  - id: cloudbees-casc-client
  - id: cloudbees-casc-items-api
  - id: cloudbees-casc-items-commons
  - id: cloudbees-casc-items-server
  - id: cloudbees-casc-server
  - id: cloudbees-casc-shared
  ```

## Create a CasC bundle location on CjoC

* assign this repository as a bundle location: `https://github.com/<YOUR_GITHUB_ORGANISATION>/ci-templates.git`  (this Organisation here would be:  https://github.com/cb-ci-templates/ci-templates.git )
  * `Manage Jenkins -> System -> Configuration as Code bundle location -> Load CasC bundles`
  * see https://docs.cloudbees.com/docs/cloudbees-ci/latest/casc-controller/add-bundle#scm-casc-bundle-location 

![CJOC-BundleLocatinSCM.png](../images/CJOC-BundleLocatinSCM.png)

You should see the bundles then under "Load CasC bundles" (left side menu)

![CJOC-LoadCasCBunlde.png](../images/CJOC-LoadCasCBunlde.png)

In CjoC CasC the configuration looks like this for the jenkins.yaml

```
unclassified:
  bundleStorageService:
    activated: true
    bundles:
    - name: "controller-ci-templates"
      retriever:
        SCM:
          ghChecksActivated: false
          scmSource:
            git:
              id: "7d2706ae-108c-4f8b-b24a-26901cd29602"
              remote: "https://github.com/cb-ci-templates/ci-templates.git"
              traits:
              - "gitBranchDiscovery"
    checkOutTimeout: 600
    pollingPeriod: 60
    purgeOnDeactivation: false

```


## Create a Controller from the bundle

You can either use this script [01-createManagedController.sh](01-createManagedController.sh)

OR follow the manual steps below: 

* Assign the bundle `main/controller-ci-templates` to the Controller provisioning 

![CJOC-Controller-provisioning-bundle.png](../images/CJOC-Controller-provisioning-bundle.png)

* Apply the yaml patch (to mount the credential secrets)

![CJOC-Controller-Yal_patch.png](../images/CJOC-Controller-Yal_patch.png)

```
---
apiVersion: "apps/v1"
kind: "StatefulSet"
spec:
template:
  metadata:
    annotations:
      cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
  spec:
    containers:
      - name: "jenkins"
        env:
        - name: SECRETS
          value: /var/run/secrets/controller
        volumeMounts:
          - name: controller-secrets
            mountPath: /var/run/secrets/controller
            readOnly: true
    volumes:
      - name: controller-secrets
        secret:
          defaultMode: 420
          secretName: controller-secrets
```


* The Cjoc full controller-items.yaml configuration looks like this [cjoc-controller-items.yaml](controller/cjoc-controller-items.yaml)


## Start the Controller

You have now a Controller created with

* the required plugins pre-installed
* the required credentials created 
* two jobs configured, ready to use

![MBJob.png](../images/MBJob.png)
![ORGJob.png](../images/ORGJob.png)

## Start/run the jobs

Note: Webhook management is not enabled by default in this demo.
You need to start the Jobs manually 

![PLExplorer.png](../images/PLExplorer.png)

#  Option2: Create Jobs by CasC API on an existing Controller 

You can use the CasC items API to create a Multibranch or GitHubOrganisation Folder Job on an existing Controller.

This requires a Controller with CasC plugins installed


## run the scripts

To create a Multibranch Pipeline
```
cd jobs
./createMultiBranchJob.sh
```
see: [item-mb-job.yaml.template](jobs/item-mb-job.yaml.template)

To create a GitHubOrganisation folder
```
cd jobs
./createGHOrganisationFolder.sh
```
see: [item-org-job.yaml.template](jobs/item-org-job.yaml.template)

# TODO

* Add support for Pipeline Template Catalog 



