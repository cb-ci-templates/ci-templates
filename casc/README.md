# Onboarding

You can use the CasC items API to create a Multibranch or GitHubOrganisation Folder Job using casc items.

## rename set-env.sh.template

> cp set-env.sh.template set-env.sh

## set your custom values

see the comments in set-env.sh

## rename cbci-secrets.yaml.template

> cp cbci-secrets.yaml.template  cbci-secrets.yaml

Update the following with your secrets

.cbci-secrets.yaml
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

## create a casc bundle location in Cjoc

* see https://docs.cloudbees.com/docs/cloudbees-ci/latest/casc-controller/add-bundle#scm-casc-bundle-location 
* assign this repository as a bundle location: https://github.com/cb-ci-templates/ci-templates.git

![CJOC-BundleLocatinSCM.png](../images/CJOC-BundleLocatinSCM.png)

You should see the bundles then under "Load casc bundles" (left side menu)

![CJOC-LoadCasCBunlde.png](../images/CJOC-LoadCasCBunlde.png)

in CasC the configuration looks like this for CjoC jenkins.yaml

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


## Create a Controller from  the bundle

* Assign the bundle `main/controller-ci-templates` to the Controller provisioning 

![CJOC-Controller-provisioning-bundle.png](../images/CJOC-Controller-provisioning-bundle.png)

* Apply the yaml patch for the secrets

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
* two jobs setup

## Start the jobs


#  Create Jobs by CasC API on an existing Controller 

You can also create a Job on an existing Controller
This requires a Controller with CasC plugins installed

* You must install  plugins required by the Pipeline template first
  * pipeline-maven
  * pipeline-utility-steps

## run the scripts

To create a Multibranch Pipeline
```
cd jobs
./createMultiBranchJob.sh
```

To create a GitHubOrganisation folder
```
cd jobs
./createGHOrganisationFolder.sh
```


# TODO

* Add support for Pipeline Template Catalog 



