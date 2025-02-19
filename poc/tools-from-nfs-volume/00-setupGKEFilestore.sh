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



# Steps to Create a PVC with ReadWriteMany in GKE
## Set Up Filestore Instance:
# * Create a Filestore instance in your GCP project.
# * Specify the desired tier (STANDARD, PREMIUM, etc.), region, and capacity for the instance.
# * Note the NFS mount point of the Filestore instance (e.g., 10.x.x.x:/nfs-share).

#gcloud filestore instances create my-filestore-instance \
#    --zone $ZONE \
#    --tier PREMIUM \
#    --file-share=name="nfs_share",capacity=2560GB \
#    --network=name="default"

#gcloud filestore instances list

#gcloud filestore instances describe my-filestore-instance --zone=$ZONE

# runs test
kubectl apply -f tools-volume-pvc.yml
# NOW YOU NEED TO WAIT SOME MINUTES
kubectl logs -n kube-system -l k8s-app=gcp-filestore-csi-driver


