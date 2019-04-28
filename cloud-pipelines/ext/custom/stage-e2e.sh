#!/bin/bash

set -o errexit

echo -e "\n\n########## Check out commit ##########"
echo "Trigger build version [${TRIGGER_BUILD_VERSION}]"
echo "Checking out commit [${TRIGGER_COMMIT_ID}]"
"${GIT_BIN}" checkout ${TRIGGER_COMMIT_ID}

echo -e "\n\n########## Run e2e tests ##########"
runE2eTests

echo -e "\n\n########## Build info summary (to archive) ##########"
echo "source=${GIT_URL}" > ci-build.properties
echo "project_name=${PROJECT_NAME}" >> ci-build.properties
echo "commit_id=${TRIGGER_COMMIT_ID}" >> ci-build.properties
echo "build_version=${TRIGGER_BUILD_VERSION}" >> ci-build.properties
echo "application_url=${APPLICATION_URL}" >> ci-build.properties

cat ci-build.properties