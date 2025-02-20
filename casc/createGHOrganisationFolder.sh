#! /bin/bash

export ÓRG_JOB_NAME
export GIT_REPO_OWNER
export GIT_HUP_APP_CREDENTIAL_ID
export MARKER_YAML
export GIT_URL_TEMPLATE
export GIT_PATH_TEMPLATE




# Controller URL where to create/update the MB job
export CONTROLLER_URL="https://<YOUR_CONTROLLER_URL>"

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
export MB_JOB_GIT_HUP_APP_CREDENTIAL_ID="ci-template-gh-app"
export MB_JOB_GIT_HUP_APP_ID="YOUR GH APP ID"
export MB_JOB_GIT_HUP_APP_PRIVATE_KEY="""
                    -----BEGIN PRIVATE KEY-----
                    YOUR GH APP PRIVATE KEY
                    -----END PRIVATE KEY-----
"""

# The custom marker yaml file name on your repo branch
export MB_GIT_CONFIG_MARKER_YAML=${4:-"ci-config.yaml"}

# The GIT repo URL oof your templates
export MB_JOB_TEMPLATE_GIT_URL="https://github.com/cb-ci-templates/ci-templates.git"

# The path to Jenkinsfile in your MB_JOB_TEMPLATE_GIT_URL
export MB_JOB_TEMPLATE_GIT_PATH="templates/mavenMultiBranch/Jenkinsfile"

# The Folder path under where to create the MB_JOB_NAME
#export FOLDER_PATH="/Pipeline-Demo"
export FOLDER_PATH="/"

# We render the CasC template,all env variables  are going to be substituted
envsubst < item-mb-job.yaml.template > ${MB_JOB_NAME}.yaml
cat ${MB_JOB_NAME}.yaml
echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items?path=${FOLDER_PATH}" \
    -H "Content-Type:text/yaml" \
   --data-binary @${MB_JOB_NAME}.yaml
