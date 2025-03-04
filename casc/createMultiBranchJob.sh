#! /bin/bash

source ./set-env.sh

# We render the CasC template,all env variables  are going to be substituted
envsubst < item-mb-job.yaml.template > MB-${JOB_NAME}.yaml
cat MB-${JOB_NAME}.yaml
echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items?path=${FOLDER_PATH}" \
    -H "Content-Type:text/yaml" \
   --data-binary @MB-${JOB_NAME}.yaml
