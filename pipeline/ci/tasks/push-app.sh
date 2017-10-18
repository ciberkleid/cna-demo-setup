#!/bin/bash

cf api $PWS_API --skip-ssl-validation

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$PWS_SPACE"

echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

# Get commit SHA of the application
app_version=$(cat $APP_NAME-src/.git/ref)

gsutil cp -R "gs://${GCP_BUCKET}/$APP_NAME/$app_version/*" $APP_NAME/

set -xe

pushd $APP_NAME

cf push -f manifest.yml --no-start

cf set-env ${APP_NAME} TRUST_CERTS $PWS_API

cf start $APP_NAME