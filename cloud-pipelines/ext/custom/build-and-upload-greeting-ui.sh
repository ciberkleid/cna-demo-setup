#!/bin/bash

set -o errexit

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
savedStubs="${STUBS}"
IFS=","
stubrunnerIDsArray=($STUBS)
length=${#stubrunnerIDsArray[@]}
#savedBuildOptions="${BUILD_OPTIONS}"

for ((i=0; i<${#stubrunnerIDsArray[@]}; ++i)); do
    echo -e "\n\n##### Testing with stubs[$i]: ${stubrunnerIDsArray[$i]}\n";
    export STUBS="${stubrunnerIDsArray[$i]}"
    #export BUILD_OPTIONS="${savedBuildOptions} -Dstubrunner.ids=${stubrunnerIDsArray[$i]}"
    if (( $i < ${#stubrunnerIDsArray[@]}-1 )); then
        runDefaultTests
    else
        echo -e "\n\n########## Build and upload ##########"
        echo -e "\nBuild will test with stubs[$i]: ${stubrunnerIDsArray[$i]}\n";
        build
    fi
done

#BUILD_OPTIONS="${savedBuildOptions}"
STUBS="${savedStubs}"
unset IFS

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