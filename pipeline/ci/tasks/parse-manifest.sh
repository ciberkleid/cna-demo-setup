#!/bin/sh

set -xe
ls ${APP_NAME}-bundle
ls ${APP_NAME}
cp -r ${APP_NAME}-bundle/* ${APP_NAME}/
cat ${APP_NAME}/manifest.yml
services=$(yaml2json < $APP_NAME/manifest.yml | jq '.applications[].services[]' |  tr -d '"')
echo $services > $APP_NAME/services.txt