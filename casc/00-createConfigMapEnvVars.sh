#! /bin/bash

source ./set-env.sh

kubectl delete configmap casc-env -n $NAMESPACE
kubectl create -n $NAMESPACE configmap casc-env \
  --from-literal=CASC_CONTROLLER_HEADER="Managed by CasC" \
  --from-literal=NAMESPACE="cjoc1" \
  --from-literal=SECRETS="/var/run/secrets/controller" \
  --from-literal=SHAREDLIB_GIT_CREDENTIALS="ci-template-gh-app" \
  --from-literal=SHAREDLIB_GIT_ORG="cb-ci-templates" \
  --from-literal=SHAREDLIB_GIT_REP="ci-shared-library" \
  --from-literal=SHAREDLIB_GIT_SERVER="https://github.com" \
  --from-literal=SHAREDLIB_GIT_TAG_DEFAULT="dev" \
  --from-literal=STAGE="dev."






