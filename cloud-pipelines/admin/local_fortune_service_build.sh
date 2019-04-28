#!/usr/bin/env bash

# Get input
RELEASE_TAGS="${1}"

# Set env
PROJECT_NAME=fortune-service
PROJECT_HOME=${FORTUNE_SERVICE_HOME}
if [[ -z "${PROJECT_HOME}" ]]; then
    PROJECT_HOME="~/workspace/spinnaker-cloud-pipelines-home/${PROJECT_NAME}"
fi
M2_SETTINGS_REPO_USERNAME="${M2_SETTINGS_REPO_USERNAME:-ciberkleid}"
M2_SETTINGS_REPO_PASSWORD="${M2_SETTINGS_REPO_PASSWORD:-OOPS_WRONG_PASSWORD}"
M2_SETTINGS_REPO_ROOT="${M2_SETTINGS_REPO_ROOT:-maven-repo}"
REPO_WITH_BINARIES=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@dl.bintray.com/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}
BUILD_OPTIONS=

# Confirm settings
echo -e "\nRunning script with the following parameters:"
echo "PROJECT_NAME=${PROJECT_NAME}"
echo "PROJECT_HOME=${PROJECT_HOME}"

pushd "${PROJECT_HOME}"

# Check API compatibility
IFS=","
releaseTagsArray=($RELEASE_TAGS)
for ((i=0; i<${#releaseTagsArray[@]}; ++i)); do
    version=${releaseTagsArray[$i]#"prod/${PROJECT_NAME}/"}
    echo -e "\n\n##### Testing with API client from version [${version}]\n\n\n";
    #executeApiCompatibilityCheck "${version}"
    ./mvnw clean verify -Papicompatibility -Dlatest.production.version="${version}" -Drepo.with.binaries="${REPO_WITH_BINARIES}" ${BUILD_OPTIONS}
done
unset IFS

# Check DB schema compatibility
CURRENT_ROOT=${PWD}
IFS=","
releaseTagsArray=($RELEASE_TAGS)
for ((i=0; i<${#releaseTagsArray[@]}; ++i)); do
    rm -rf ../${PROJECT_NAME}-temp
    mkdir -p ../${PROJECT_NAME}-temp
    cd ../${PROJECT_NAME}-temp
    tag="${releaseTagsArray[$i]}"
    git checkout ${tag} || { echo >&2 "git checkout failed with $?"; return 1; }
    echo -e "\n\n##### Testing [${tag}] against current DB schema\n\n\n";
    rm -r src/main/resources/db/migration
    mkdir -p src/main/resources/db
    cp -r ${CURRENT_ROOT}/src/main/resources/db/migration src/main/resources/db/migration
    #runDefaultTests
    ./mvnw clean test -Pdefault ${BUILD_OPTIONS}
done
rm -rf ../${PROJECT_NAME}-temp
unset IFS

echo -e "\nBuilding project\n"
cd ${CURRENT_ROOT}
./mvnw clean install ${BUILD_OPTIONS}

popd
