# Setup

You can use this Controller CasC [controller-ci-templates](controller/controller-ci-templates) bundle to create a Controller that has everything setup. including: 
* all required plugins 
* all required Credentials 
* a pre-configured MultiBranch and GitHub Organisation Job setup (referencing this template repository)

## Steps

* fork the following repositories in your own GitHub organisation:
  * https://github.com/cb-ci-templates/ci-templates
  * https://github.com/cb-ci-templates/ci-shared-library
  * https://github.com/cb-ci-templates/sample-app-spring-boot-maven
* Clone the https://github.com/cb-ci-templates/ci-templates to your terminal and follow the instructions below
*  

## Set environment

* rename `set-env.sh.template`

> cp set-env.sh.template set-env.sh

* set your custom values, see all the comments `CHANGE ME` in `set-env.sh`

## Create Credentials

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

> ./00-createCredentialSecrets.sh

# Option1: Create a Controller from Controller CasC bundle

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

* assign this repository as a bundle location: https://github.com/cb-ci-templates/ci-templates.git
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


In CasC the full configuration looks like: 

```
kind: managedController
name: controller-ci-templates
configuration:
  kubernetes:
    allowExternalAgents: false
    terminationGracePeriodSeconds: 1200
    image: CloudBees CI - Managed Controller - latest
    memory: 3072
    startupPeriodSeconds: 10
    fsGroup: '1000'
    cpus: 1.0
    readinessTimeoutSeconds: 5
    startupFailureThreshold: 100
    livenessInitialDelaySeconds: 300
    readinessInitialDelaySeconds: 30
    clusterEndpointId: default
    disk: 50
    readinessFailureThreshold: 100
    livenessTimeoutSeconds: 10
    storageClassName: ssd-cloudbees-ci-cloudbees-core
    domain: controller-ci-templates
    livenessPeriodSeconds: 10
    startupTimeoutSeconds: 5
    startupInitialDelaySeconds: 30
    javaOptions: -XshowSettings:vm -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled
      -XX:+UseStringDeduplication -XX:+AlwaysActAsServerClassMachine -Dhudson.slaves.NodeProvisioner.initialDelay=0
    yaml: |-
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
description: ''
displayName: controller-ci-templates
properties:
- configurationAsCode:
    bundle: dev/controller-ci-templates
- customWebhookData: {
    }
- sharedHeaderLabelOptIn:
    optIn: true
- healthReporting:
    enabled: true
- optOutProperty:
    securityEnforcerOptOutMode:
      optOutNone: {
        }
- owner:
    delay: 5
    owners: ''
- envelopeExtension:
    allowExceptions: false
- sharedConfigurationOptOut:
    optOut: false

```

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

## Pre-requirements:

* A CloudBees CI Controller (modern)
* Plugins referenced in the sample template
  * https://plugins.jenkins.io/pipeline-maven
  * https://www.jenkins.io/doc/pipeline/steps/junit
  * https://plugins.jenkins.io/build-discarder  (will be removed soon)
  * https://plugins.jenkins.io/pipeline-utility-steps
  * These Plugins are referenced from
    * https://github.com/cb-ci-templates/ci-templates/blob/main/templates/mavenMultiBranch/Jenkinsfile
    * https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/pipelineMaven.groovy
* Dockerconfig Credential 
  * description: "credential to pull/push to dockerhub"
  * type: "Secret file"
  * credentialId: dockerconfig
  * filecontent: dockerconfig.json
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



