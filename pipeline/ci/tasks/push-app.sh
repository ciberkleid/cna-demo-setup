#!/bin/bash

cf api $PWS_API --skip-ssl-validation

echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

set -xe

echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')
environment=$(jq '.environment' ./application-spec/$app_spec_file  |  tr -d '"')

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$environment"

for application in $applications ; do 
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')
    mkdir -p app
    gsutil cp -R "gs://${GCP_BUCKET}/artifacts/$application/$gittag/*" app/

    cd app    
    sed -i "/path/c\  path: $application-$gittag.jar" $application-$gittag-manifest.yml
    cf push -f $application-$gittag-manifest.yml --no-start
    cf set-env $application TRUST_CERTS $PWS_API
    cf start $application

    cd ..
    rm -rf app
done
