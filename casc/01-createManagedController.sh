#! /bin/bash

source ./set-env.sh




echo "Verify if PVC ${CONTROLLER_NAME}-0  exist"
if [ -n "$(kubectl get pvc jenkins-home-$CONTROLLER_NAME-0)" ]
then
  #see https://docs.cloudbees.com/docs/cloudbees-ci-kb/latest/operations-center/how-to-delete-a-managed-controller-in-cloudbees-jenkins-enterprise-and-cloudbees-core
   echo "PVC jenkins-home-$CONTROLLER_NAME-0 exist, will be deleted now"
   kubectl delete pvc jenkins-home-$CONTROLLER_NAME-0
fi

echo "------------------  CREATING MANAGED CONTROLLER ------------------"
#see https://docs.cloudbees.com/docs/cloudbees-ci-api/latest/bundle-management-api
curl -v -XPOST \
   --user $TOKEN \
   "${CJOC_URL}/casc-items/create-items" \
    -H "Content-Type:text/yaml" \
   --data-binary @controller/cjoc-controller-items.yaml
