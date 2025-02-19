#!/usr/bin/env bash

# see https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/filestore-csi-driver?hl=de


# FOR HA CONTROLLER WE NEED THIS STIORAGE CLASS
# premium-rwx                       filestore.csi.storage.gke.io   Delete          WaitForFirstConsumer   true

export CLUSTER_NAME=<YOUR_CLUSTER_NAME>
export ZONE=<YOUR_ZONE>
export PROJECT_ID=<YOUR_PROJECT_ID>

gcloud services enable cloudresourcemanager.googleapis.com  --project ${PROJECT_ID}
gcloud services enable compute.googleapis.com --project ${PROJECT_ID}
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
gcloud services enable secretmanager.googleapis.com --project ${PROJECT_ID}
gcloud services enable file.googleapis.com --project ${PROJECT_ID}
sleep 10

# Install CSI driver
gcloud container clusters update $CLUSTER_NAME \
    --update-addons=GcpFilestoreCsiDriver=ENABLED \
    --region $ZONE # Or --zone for zonal clusters

#Verify
kubectl get pods -n kube-system -l  k8s-app=gcp-filestore-csi-driver

# runs test
kubectl apply -f tools-volume-pvc.yml
echo "NOW YOU NEED TO WAIT SOME MINUTES UNTIL THE FILESTORE IS CREATED AND ASSIGNED; CHECK YOUR GCP CONSOLE FOR READINESS"
POD_NAME=tools-pod
while true; do
  STATUS=$(kubectl get pod $POD_NAME -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  if [ "$STATUS" == "True" ]; then
    echo "Pod $POD_NAME is ready."
    break
  else
    echo "Pod $POD_NAME is not ready yet. Checking again in 10 seconds..."
    sleep 10
  fi
done

kubectl logs -n kube-system -l k8s-app=gcp-filestore-csi-driver


