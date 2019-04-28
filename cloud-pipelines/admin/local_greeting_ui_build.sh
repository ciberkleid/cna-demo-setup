#!/usr/bin/env bash

# Get input
STUBS="${1}"
WORK_OFFLINE="${2:-true}"

# Set env
PROJECT_NAME=greeting-ui
PROJECT_HOME="${GREETING_UI_HOME}"
if [[ -z "${PROJECT_HOME}" ]]; then
    PROJECT_HOME="~/workspace/spinnaker-cloud-pipelines-home/${PROJECT_NAME}"
fi
M2_SETTINGS_REPO_USERNAME="${M2_SETTINGS_REPO_USERNAME:-ciberkleid}"
M2_SETTINGS_REPO_PASSWORD="${M2_SETTINGS_REPO_PASSWORD:-OOPS_WRONG_PASSWORD}"
M2_SETTINGS_REPO_ROOT="${M2_SETTINGS_REPO_ROOT:-maven-repo}"
REPO_WITH_BINARIES=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@dl.bintray.com/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}
BUILD_OPTIONS="${BUILD_OPTIONS} -Dstubrunner.snapshot-check-skip=true"

if [[ $WORK_OFFLINE ]]; then
    BUILD_OPTIONS="${BUILD_OPTIONS} -Dstubrunner.stubs-mode=LOCAL"
fi

# Confirm settings
echo -e "\nRunning script with the following parameters:\n"
echo "PROJECT_NAME=${PROJECT_NAME}"
echo "PROJECT_HOME=${PROJECT_HOME}"
echo "WORK_OFFLINE=${WORK_OFFLINE}"

pushd "${PROJECT_HOME}"

# Check against provided stubs
# Need to test one at a time for now due to a port binding error
IFS=","
stubrunnerIDsArray=($STUBS)
length=${#stubrunnerIDsArray[@]}
savedBuildOptions="${BUILD_OPTIONS}"

for ((i=0; i<${#stubrunnerIDsArray[@]}; ++i)); do
    echo -e "\n\n##### Testing with stubs[$i]: ${stubrunnerIDsArray[$i]}\n";
    BUILD_OPTIONS="${savedBuildOptions} -Dstubrunner.ids=${stubrunnerIDsArray[$i]}"
    if [[ $i<${#stubrunnerIDsArray[@]}-1 ]]; then
        ./mvnw clean test -Pdefault -Drepo.with.binaries="${REPO_WITH_BINARIES}" ${BUILD_OPTIONS}
    else
        echo -e "\nThis stub will be used for the build...\n";
        # Call build after for loop, in case no stub was provided at all
    fi
done

 echo -e "\n\n########## Build and upload ##########"
 ./mvnw clean install ${BUILD_OPTIONS}

BUILD_OPTIONS="${savedBuildOptions}"
unset IFS

popd
