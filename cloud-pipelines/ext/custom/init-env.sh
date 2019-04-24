#!/bin/bash

# The cloud-pipelines extension bootstrap.sh script sources this file
# Make sure your CI job executes the code in the bootstrap.sh file
# Your CI job should also overwrite M2_SETTINGS_REPO_USERNAME and
# set the M2_SETTINGS_REPO_PASSWORD

echo -e "\n\n########## Set up Cloud Pipelines extended environment ##########"
export NUM_SOURCED_EXT_FILES=0
source "${WORKSPACE_EXT}"/pipeline.sh
source "${WORKSPACE_EXT}"/projectType/pipeline-maven.sh
echo "NUM_SOURCED_EXT_FILES=${NUM_SOURCED_EXT_FILES}"

echo -e "\n\n########## Set up maven repo environment ##########"
export M2_SETTINGS_REPO_ID=bintray
export M2_SETTINGS_REPO_USERNAME=ciberkleid
export M2_SETTINGS_REPO_ROOT=maven-repo
echo "M2_SETTINGS_REPO_ID=[${M2_SETTINGS_REPO_ID}]"
echo "M2_SETTINGS_REPO_USERNAME=[${M2_SETTINGS_REPO_USERNAME}]"
echo "M2_SETTINGS_REPO_ROOT=[${M2_SETTINGS_REPO_ROOT}]"
if [[  -z "${M2_SETTINGS_REPO_PASSWORD}" ]]; then
    echo -e "\nWARNING: M2_SETTINGS_REPO_PASSWORD is empty.\n"
fi
export REPO_WITH_BINARIES_FOR_UPLOAD=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@api.bintray.com/maven/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}
export REPO_WITH_BINARIES=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@dl.bintray.com/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}


echo -e "\n\n########## Set up common project environment ##########"
export PROJECT_NAME="$(extractMavenProperty "project.artifactId")"
echo "PROJECT_NAME=[${PROJECT_NAME}]"
export REPO_WITH_BINARIES_FOR_UPLOAD="${REPO_WITH_BINARIES_FOR_UPLOAD}/${PROJECT_NAME}"
export BUILD_OPTIONS="-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"
export STUBRUNNER_SNAPSHOT_CHECK_SKIP=true
