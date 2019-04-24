#!/bin/bash

set -o errexit

export STUBS

echo -e "\n\n########## Generate version for this build ##########"
export PASSED_PIPELINE_VERSION=$(generateVersion)
echo "Project Name [${PROJECT_NAME}]"
echo "Version [${PASSED_PIPELINE_VERSION}]"

echo -e "\n\n########## Get stub coordinates ##########"
if [[ ! -z "${STUBS}" ]]; then
   echo "Using release list from input parameter:"
   echo "${STUBS}"
else
  echo "Using release list published by collaborator(s):"
  echo "---- Raw file contents ----"
  cat "${WORKSPACE}"/.git/tools-releases/fortune-service/ci-releases.properties
  echo "---- Raw file contents (end) ----"
  # File format is [tag=coordinates\n]. Convert to comma-separated list of coordinates.
  separator="" # Blank until first run through loop
  while read line; do
    coordinates=$(echo ${line} | cut -d "=" -f2)
  	#echo "Adding coordinates [${coordinates}]"
	STUBS="${STUBS}${separator}${coordinates}"
    separator="," # will be populated after first coordinates are set
  done < "${WORKSPACE}"/.git/tools-releases/fortune-service/ci-releases.properties
  echo -e "\nExtracted coordinates (comma-separated list):"
  echo "${STUBS}"
fi

echo -e "\n\n########## Test stubs ##########"
# Need to test one at a time for now due to a port binding error
savedStubs=${STUBS}
IFS=","
stubrunnerIDsArray=($STUBS)
length=${#stubrunnerIDsArray[@]}

# The build uses a stub, so if the array contains only one stub, skip to build
if [[ "$length" -eq 1 ]]; then
	echo "Exactly one stub provided. Skipping to build (build will test against this stub)."
else
    echo -e "\nFirst stub (stubs[0]) will be tested during the build."
    echo -e "Starting tests with second stub (stubs[1]).\n"
fi
# Start with index=1 (index=0 will be tested during the build)
for ((i=1; i<${#stubrunnerIDsArray[@]}; ++i)); do
	STUBS="${stubrunnerIDsArray[$i]}"
    echo -e "\nTesting with stubs[$i]: ${STUBS}\n";
    runDefaultTests
done
unset IFS

echo -e "\n\n########## Build and upload ##########"
STUBS="${stubrunnerIDsArray[0]}"
echo -e "\nBuild will test with stubs[0]: ${STUBS}";
build

# Re-set STUBS workaround to binding error
STUBS=${savedStubs}

echo -e "\n\n########## Publish uploaded files ##########"
api=${REPO_WITH_BINARIES_FOR_UPLOAD/maven/content}
curl -X POST ${api}/${PASSED_PIPELINE_VERSION}/publish

echo -e "\n\n########## Build info summary (to archive) ##########"
echo "source=${GIT_URL}" > ci-build.properties
echo "project_name=${PROJECT_NAME}" >> ci-build.properties
echo "commit_id=${GIT_COMMIT}" >> ci-build.properties
echo "build_version=${PASSED_PIPELINE_VERSION}" >> ci-build.properties
echo "api_compat=${STUBS}" >> ci-build.properties

cat ci-build.properties