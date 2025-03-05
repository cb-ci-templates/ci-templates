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


## run the scripts

To create a Multibranch Pipeline
> ./createMultiBranchJob.sh


To create a GitHubOrganisation folder
> ./createGHOrganisationFolder.sh


# TODO

* Docker push in the Kaniko push step fails.Docker credentials are missing. Need to add docker credentials
* Add support for Pipeline Template Catalog 



