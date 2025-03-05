#! /bin/bash


source ../set-env.sh

# We render the CasC template,all env variables  are going to be substituted
envsubst < item-org-job.yaml.template > ORG-${JOB_NAME}.yaml
cat ORG-${JOB_NAME}.yaml
echo "------------------  CREATING MANAGED CONTROLLER ------------------"
curl -v -XPOST \
   --user $TOKEN \
   "${CONTROLLER_URL}/casc-items/create-items?path=${FOLDER_PATH}" \
    -H "Content-Type:text/yaml" \
   --data-binary @ORG-${JOB_NAME}.yaml
