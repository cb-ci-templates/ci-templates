# Onboarding

You can use the CasC items API to create a Multibranch or GitHubOrganisation Folder Job using casc items.

## rename set-env.sh.template

> cp set-env.sh.template set-env.sh

## Adjust you custom values

see the comments in set-env.sh

## run the scripts

To create a Multibranch Pipeline
> ./createMultiBranchJob.sh


To create a GitHubOrganisation folder
> ./createGHOrganisationFolder.sh


# TODO

* Docker push in the Kaniko push step fails.Docker credentials are missing. Need to add docker credentials
* Add support for Pipeline Template Catalog 



