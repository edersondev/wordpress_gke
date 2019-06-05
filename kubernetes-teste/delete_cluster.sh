#!/bin/bash

PROJECT=$(gcloud config get-value project)
REGION=us-central1
ZONE=${REGION}-b
CLUSTER=gke-load-test
gcloud config set compute/region $REGION 
gcloud config set compute/zone $ZONE

echo "Deletando pasta"
rm -rf gke-load-test

echo "Deletando imagem"
gcloud container images delete gcr.io/$PROJECT/locust-tasks --force-delete-tags --quiet

echo "Deletando cluster"
gcloud container clusters delete $CLUSTER --zone $ZONE --quiet