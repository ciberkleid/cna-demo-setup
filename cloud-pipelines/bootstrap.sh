#!/bin/bash

# Your CI server jobs should execute this script
# This will download the Cloud Pipelines source as well as the custom extensions source
# This will also source files from both downloads to set up the environment
# See files in distro downloaded below for options of job scripts to call

#!/bin/bash

echo -e "\n\n########## Run common scripts ##########"

rm -rf .git/tools-ext && mkdir -p .git/tools-ext && cd "${WORKSPACE}"/.git/tools-ext && curl -Lk "https://github.com/ciberkleid/cna-demo-setup/raw/master/cloud-pipelines/dist/cloud-pipelines-ext.tar.gz" -o pipelines-ext.tar.gz && tar xf pipelines-ext.tar.gz && cd "${WORKSPACE}"

# Overwrite default values by setting M2_SETTINGS_REPO_USERNAME and
# M2_SETTINGS_REPO_ROOT as apporpriate for your Bintray account
# Se the custom/init-env.sh file for the default values
#export M2_SETTINGS_REPO_USERNAME=<your bintray username>
#export M2_SETTINGS_REPO_ROOT=<your bintray maven repo name>

source "${WORKSPACE}"/.git/tools-ext/custom/init-env.sh

echo -e "\n\n########## Run job script ##########"

source "${WORKSPACE_EXT}"/<enter-the-proper-job-script-filename-here>.sh