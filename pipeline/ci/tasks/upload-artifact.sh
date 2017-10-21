#!/bin/bash

set -xe

echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

# Main
echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')

ls -a application-bundle/*

for application in $applications ; do 
    
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')

    gsutil cp -r application-bundle/$application/$gittag/* "gs://${GCP_BUCKET}/artifacts/$application/$gittag"
    
done
