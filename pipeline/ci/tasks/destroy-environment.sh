#!/bin/bash

cf api $PWS_API --skip-ssl-validation

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$PWS_SPACE"

# Create space if it doesn't exist
cf spaces | grep $PWS_SPACE > /dev/null || cf create-space $PWS_SPACE 

echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

for app in $APP_NAME; do
    # Get commit SHA of the application
    app_version=$(cat $app-src/.git/ref)

    gsutil cp "gs://${GCP_BUCKET}/$app/$app_version/services.txt" ./

    services=$(cat services.txt)
    cf delete $app -r -f

    for service in $services; do
        cf delete-service $service -f
    done    
done
