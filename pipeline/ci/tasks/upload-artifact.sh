#!/bin/bash


echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

set -xe
# Get commit SHA of the application
app_version=$(cat $APP_NAME-src/.git/ref)
ls -a $APP_NAME/*
cd $APP_NAME
gsutil cp -r ./ "gs://${GCP_BUCKET}/$APP_NAME/$app_version"

set -xe