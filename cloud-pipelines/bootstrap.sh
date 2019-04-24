#!/bin/bash

# Your CI server jobs should execute this script
# This will download the Cloud Pipelines source as well as the custom extensions source
# This will also source files from both downloads to set up the environment

echo -e "\n\n########## ---------- Set up Cloud Pipelines environment ---------- ##########"
rm -rf .git/tools && mkdir -p .git/tools && cd "${WORKSPACE}"/.git/tools && curl -Lk "https://github.com/CloudPipelines/scripts/raw/master/dist/scripts.tar.gz" -o pipelines.tar.gz && tar xf pipelines.tar.gz --strip-components 1 && cd "${WORKSPACE}"

if [[ -z $(which ruby) ]]; then
    echo -e "\nRuby is not installed. Disabling ruby calls.\n"
    function ruby() { echo ""; }; export -f ruby
fi

export ENVIRONMENT=BUILD
export CI=Jenkins

#export ADDITIONAL_SCRIPTS_TARBALL_URL="https://github.com/ciberkleid/cna-demo-setup/raw/master/cloud-pipelines/dist/cloud-pipelines-ext.tar.gz"

source "${WORKSPACE}"/.git/tools/src/main/bash/pipeline.sh

echo -e "\n\n########## ---------- Set up Cloud Pipelines Extensions ---------- ##########"
rm -rf .git/tools-ext && mkdir -p .git/tools-ext && cd "${WORKSPACE}"/.git/tools-ext && curl -Lk "https://github.com/ciberkleid/cna-demo-setup/raw/master/cloud-pipelines/dist/cloud-pipelines-ext.tar.gz" -o pipelines-ext.tar.gz && tar xf pipelines-ext.tar.gz && cd "${WORKSPACE}"

export WORKSPACE_EXT="${WORKSPACE}/.git/tools-ext/custom"
echo -e "\nExtensions can be accessed using WORKSPACE_EXT env variable"
echo "WORKSPACE_EXT=${WORKSPACE_EXT}"

source "${WORKSPACE_EXT}"/init-env.sh

find "${WORKSPACE_EXT}" -type f -iname "*.sh" -exec chmod +x {} \;

echo -e "\n\n########## ---------- End Cloud Pipelines & Extensions setup ---------- ##########"
