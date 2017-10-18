#!/bin/bash

set -xe

# Maven Fortune Service
cd $APP_NAME-src
mvn clean install
cd ..

mkdir -p $APP_NAME-bundle/target/
mv $APP_NAME-src/target/$APP_NAME-*.jar $APP_NAME-bundle/target/
mv $APP_NAME-src/manifest.yml $APP_NAME-bundle/
set -xe