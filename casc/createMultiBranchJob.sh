#! /bin/bash

# Controller URL where to create/update the MB job
export CONTROLLER_URL="https://sda.acaternberg.flow-training.beescloud.com/controller-test"

# Admin Jenkins Token
export TOKEN="ADMIN_ID:TOKEN"

# MB JobName
export MB_JOB_NAME=${1:-"MB_NEW_MB_JOB"}

# The GIT Organisation name
export MB_GIT_REPO_OWNER=${2:-"cb-ci-templates"}

# The GIT repo name (Your App reponame)
export MB_GIT_REPO_NAME=${3:-"sample-app-spring-boot-maven"}

# The credentials id of your GitHub App credentials
#see https://docs.cloudbees.com/docs/cloudbees-ci/latest/traditional-admin-guide/github-app-auth
export MB_JOB_GIT_HUP_APP_CREDENTIAL_ID=${4:-"ci-template-gh-app"}

# The custom marker yaml file name on your repo branch
export MB_GIT_CONFIG_MARKER_YAML=${5:-"ci-config.yaml"}

# The GIT repo URL oof your templates
export MB_JOB_TEMPLATE_GIT_URL="https://github.com/cb-ci-templates/ci-templates.git"

# The path to Jenkinsfile in your MB_JOB_TEMPLATE_GIT_URL
export MB_JOB_TEMPLATE_GIT_PATH="templates/mavenMultiBranch/Jenkinsfile"

# The Folder path under where to create the MB_JOB_NAME
#export FOLDER_PATH="/Pipeline-Demo"
export FOLDER_PATH="/"

# We render the CasC template instances for the casc-folder (target folder)
# All variables from the envvars.sh will be substituted
envsubst < item-mb-job.yaml.template > ${MB_JOB_NAME}.yaml

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items?path=${FOLDER_PATH}" \
    -H "Content-Type:text/yaml" \
   --data-binary @${MB_JOB_NAME}.yaml
