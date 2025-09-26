# Setup

The following instruction describes how to setup a pre-provisioned Controller including
* all required plugins
* all required Credentials
* a MultiBranch and GitHub Organisation Job, ready to  
  * use this Pipeline template [3-multiBranch](../templates/3-multiBranch)
  * referencing a spring-boot sample application repo https://github.com/cb-ci-templates/sample-app-spring-boot-maven

# What you need

* A CloudBees CI installation on Kubernetes (setup managed by YOU)
* A CI Controller setup with:
  * Credentials
    * A GitHub App credential token (used by some Pipeline templates)
    * A Docker Hub Credential (used by some Pipeline templates)
  * Plugins
    * referenced by the Pipeline templates
  * Kubernetes Configmap
    * used to inject environment variables in the Pod agents (container env) so they can referenced by the Pipeline templates
* An GitHub organisation 
  * To host your repositories of the Pipeline Templates and Shared Library etc.

# Create a CI Controller 


Setup a CI Controller. You can either use the Operations Center UI for that or Configuration as Code (CasC)  
to get a pre-provisioned Controller (see [controller-ci-templates](controller/controller-ci-templates)).


## Credentials

On the Controller, the following Credentials are required:
See also Credentials: (setup managed by CasC, [credentials.yaml](controller/controller-ci-templates/credentials.yaml))

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

## Plugins

The following Plugins are required
See also Plugin setup managed by CasC, [plugins.yaml](controller/controller-ci-templates/plugins.yaml)

* Plugins referenced in the sample templates
  * https://plugins.jenkins.io/pipeline-maven
  * https://www.jenkins.io/doc/pipeline/steps/junit
  * https://plugins.jenkins.io/build-discarder  (will be removed soon)
  * https://plugins.jenkins.io/pipeline-utility-steps (tier 3 plugin)
  * These Plugins are referenced from
    * https://github.com/cb-ci-templates/ci-templates/blob/main/templates/mavenMultiBranch/Jenkinsfile
    * https://github.com/cb-ci-templates/ci-shared-library/blob/main/vars/pipelineMaven.groovy

## Environment Variables

To inject IT controls and environment variables to the template and build container, we use K8s configmaps
* We need at least an empty configmap named `configmap-envvars`
* The configmap is referenced by all build pods, pod will fail if the configmap doesnt exist 

See [configmap-env-vars-default.yaml](../config/configmap-env-vars-default.yaml)
 
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-envvars
data: {}
```
F.e. to setup proxy variables in our build comtext, we can use a configmap like this:
see [configmap-env-vars-proxy.yaml](../config/configmap-env-vars-proxy.yaml)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-envvars
data:
  HTTP_PROXY:  http://squid-dev-proxy.squid.svc.cluster.local:3128
  HTTPS_PROXY: http://squid-dev-proxy.squid.svc.cluster.local:3128
  .....
```

The configmaps will be referenced by build pods from the Pipeline templates like this:
See also https://github.com/cb-ci-templates/ci-shared-library/tree/main/resources/podtemplates
```
kind: Pod
metadata:
  name: maven
spec:
  containers:
    - name: maven
      image: maven:3.9.9-amazoncorretto-17
      envFrom:
        - configMapRef:
            name: configmap-envvars
```

Means: if the configmap doesnt exist, the pod might fail to start 

Create the default configmap like this:

```
kubectl apply -f config/configmap-env-vars-default.yaml
```
or with Proxy vars

```
kubectl apply -f config/configmap-env-vars-proxy.yaml
```

# Fork the Pipeline Template repositories

* Fork the following repositories in your own GitHub organisation:
  * https://github.com/cb-ci-templates/ci-templates
  * https://github.com/cb-ci-templates/ci-shared-library
  * https://github.com/cb-ci-templates/sample-app-spring-boot-maven
* and clone the copies to your terminal

# Update Shared Library references

You can control the location and version of the Shared Library referenced by the Pipeline template with these environment variables:

```
SHAREDLIB_GIT_SERVER="https://github.com"
SHAREDLIB_GIT_ORG="cb-ci-templates"
SHAREDLIB_GIT_REP="ci-shared-library"
SHAREDLIB_GIT_TAG_DEFAULT="main" # "dev" # v1.12
SHAREDLIB_GIT_CREDENTIALS="ci-template-gh-app"
```

In your forked version of the Templates, you need to adjust this by updating the reference to the shared library in the template [Jenkinsfile](../templates/mavenMultiBranch/Jenkinsfile)
Currently, there is a reference to the shared library hosted in this GitHub Organisation.
Since you cloned the Shared Library to your organisation, you might want to update the repository URL
Update the following:

From
```
env.SHAREDLIB_GIT_ORG="cb-ci-templates" //"cb-ci-templates"
```
To
```
env.SHAREDLIB_GIT_ORG="<YOUR_GITHUB_ORGANISATON>" //"cb-ci-templates"
```

Then, push your updates to git. 
You can also manage those as environment variable on Job or Folder level.
If you don`t do it, the template references still to the original Library (Which is ok for testing/demo purpose)


# Create a Controller from Controller CasC bundle

## Set environment

* rename `set-env.sh.template`

> cp set-env.sh.template set-env.sh

* set your custom values, see all the comments `CHANGE ME` in `set-env.sh`

## Create Credentials

Two credentials are required for:

* This CasC setup reads credentials in CasC from K8s secret. However, In production, external secret managers are strongly recommended (aws secret manager, vault etc)

* rename `cbci-secrets.yaml.template`

> cp cbci-secrets.yaml.template  cbci-secrets.yaml

* Update `cbci-secrets.yaml` with your secrets
  * NOTE: It is important to preserver the indents as shown below!

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
  * The setup of the CasC bundle from SCM assumes hat your repositoriy is public and no credentials are required to clone. (Can be secured if required, bzut than requirs )

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

* Assign the bundle `main/controller-ci-templates` during the Controller provisioning

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

## ⚙️ Job Settings: Branch Suppression Strategies

Suppress automatic triggering for all branches, except PRs:

```yaml
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
