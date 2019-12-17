#!/bin/bash
PROJECT='ansible-gce-262114'
SERVICE_ACCOUNT='ansible@ansible-gce-262114.iam.gserviceaccount.com'
ZONE='europe-west1-b'

time gcloud compute instances create web-1 \
  --project $PROJECT \
  --zone $ZONE \
  --machine-type g1-small \
  --network default \
  --subnet default \
  --network-tier PREMIUM \
  --maintenance-policy MIGRATE \
  --service-account $SERVICE_ACCOUNT \
  --scopes https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --tags apache-http-server \
  --image ubuntu-1804-lts \
  --image project centos-cloud \
  --boot-disk-size 20GB \
  --boot-disk-type pd-standard \
  --boot-disk-device-name compute-disk

time gcloud compute firewall-rules create default-allow-http \
  --project $PROJECT \
  --description 'Allow HTTP from anywhere' \
  --direction INGRESS \
  --priority 1000 \
  --network default \
  --action ALLOW \
  --rules tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags apache-http-server
