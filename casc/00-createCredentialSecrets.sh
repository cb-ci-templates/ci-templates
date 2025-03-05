#! /bin/bash

source ./set-env.sh



kubectl delete secret controller-secrets -n $NAMESPACE

kubectl create secret generic controller-secrets -n $NAMESPACE \
    --from-literal=gitHubAppId="$(yq '.gitHubAppId' cbci-secrets.yaml )" \
    --from-literal=gitHubAppPrivateKey="$(yq '.gitHubAppPrivateKey' cbci-secrets.yaml )" \
    --from-literal=dockerConfigJson="$(yq '.dockerConfigJson' cbci-secrets.yaml )"






