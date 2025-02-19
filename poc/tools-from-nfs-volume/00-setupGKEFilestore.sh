#!/usr/bin/env bash

# see https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/filestore-csi-driver?hl=de


# FOR HA CONTROLLER WE NEED THIS STIORAGE CLASS
# premium-rwx                       filestore.csi.storage.gke.io   Delete          WaitForFirstConsumer   true



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
#kubectl get pods -n kube-system -l app.kubernetes.io/name=gcp-filestore-csi-driver
#kubectl get pods -n kube-system -l app.kubernetes.io/k8s-app=gcp-filestore-csi-driver
kubectl get pods -n kube-system -l  k8s-app=gcp-filestore-csi-driver

# runs test
kubectl apply -f tools-volume-pvc.yml
echo "NOW YOU NEED TO WAIT SOME MINUTES UNTIL THE FILESTORE IS CREATED AND ASSIGNED; CHECK YOUR GCP CONSOLE FOR READINESS"
kubectl logs -n kube-system -l k8s-app=gcp-filestore-csi-driver


