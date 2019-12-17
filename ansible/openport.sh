#!bin/bash
PROJECT='ansible-gce-262114'
SERVICE_ACCOUNT='ansible@ansible-gce-262114.iam.gserviceaccount.com'
ZONE='europe-west1-b'
time gcloud compute firewall-rules create default-allow-tomcat \
  --project $PROJECT \
  --description 'Allow HTTP from anywhere' \
  --direction INGRESS \
  --priority 1000 \
  --network default \
  --action ALLOW \
  --rules tcp:8080 \
  --source-ranges 0.0.0.0/0 \
  --target-tags apache-tomcat
