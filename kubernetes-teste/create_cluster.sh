#!/bin/bash

PROJECT=$(gcloud config get-value project)
REGION=southamerica-east1
ZONE=${REGION}-b
CLUSTER=gke-load-test
TARGET=www.poder360.com.br
gcloud config set compute/region $REGION 
gcloud config set compute/zone $ZONE

if [ "$1" = "delete" ] ; then
	gcloud container clusters delete $CLUSTER --zone $ZONE
	exit
fi

gcloud services enable \
    cloudbuild.googleapis.com \
    compute.googleapis.com \
    container.googleapis.com \
    containeranalysis.googleapis.com \
    containerregistry.googleapis.com

gcloud container clusters create $CLUSTER \
         --zone $ZONE \
         --scopes "https://www.googleapis.com/auth/cloud-platform" \
         --num-nodes "3" \
         --enable-autoscaling --min-nodes "3" \
         --max-nodes "10" \
         --addons HorizontalPodAutoscaling,HttpLoadBalancing

gcloud container clusters get-credentials $CLUSTER \
 --zone $ZONE \
 --project $PROJECT
 
git clone https://github.com/GoogleCloudPlatform/distributed-load-testing-using-kubernetes.git gke-load-test

pushd gke-load-test

sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml

kubectl apply -f kubernetes-config/locust-master-controller.yaml
kubectl apply -f kubernetes-config/locust-master-service.yaml
kubectl apply -f kubernetes-config/locust-worker-controller.yaml

EXTERNAL_IP=$(kubectl get svc locust-master -o yaml | grep ip | awk -F":" '{print $NF}')

echo "http://$EXTERNAL_IP:8089"