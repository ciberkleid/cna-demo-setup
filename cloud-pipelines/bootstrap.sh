#!/bin/bash

# Your CI server jobs should execute this script
# This script will download & source the Cloud Pipelines scripts and
# extensions scripts, and it will execute your job script of choice

####################
# Configure this section
# Set your Bintray username and maven repo root
# Set job script to run. Check extensions archive for options/examples.

M2_SETTINGS_REPO_USERNAME="ciberkleid"
M2_SETTINGS_REPO_ROOT="maven-repo"

jobScript="build-and-upload-fortune-service.sh"

####################
# The following section does not require configuration

echo -e "\n\n########## Run common scripts ##########"

rm -rf .git/tools-ext && mkdir -p .git/tools-ext && cd "${WORKSPACE}"/.git/tools-ext && curl -Lk "https://github.com/ciberkleid/cna-demo-setup/raw/master/cloud-pipelines/dist/cloud-pipelines-ext.tar.gz" -o pipelines-ext.tar.gz && tar xf pipelines-ext.tar.gz && cd "${WORKSPACE}"
source "${WORKSPACE}"/.git/tools-ext/custom/init-env.sh

echo -e "\n\n########## Run job script ##########"
echo "Executing script: [${jobScript}]"
source "${WORKSPACE_EXT}/${jobScript}"