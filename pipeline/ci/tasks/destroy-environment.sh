#!/bin/bash

cf api $PWS_API --skip-ssl-validation

app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')
environment=$(jq '.environment' ./application-spec/$app_spec_file  |  tr -d '"')

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$environment"

echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

for application in $applications; do
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')    

    gsutil cp "gs://${GCP_BUCKET}/artifacts/$application/$gittag/$application-$gittag-services.txt" ./

    services=$(cat $application-$gittag-services.txt)
    cf delete $application -r -f

    for service in $services; do
        cf delete-service $service -f
    done    
done
