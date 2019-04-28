#!/bin/bash

set -o errexit

echo -e "\n\n########## Generate version for this build ##########"
echo "Project Name [${PROJECT_NAME}]"
echo "Project Version [${PROJECT_VERSION}]"
export PASSED_PIPELINE_VERSION=$(generateVersion)
echo "Generated Version [${PASSED_PIPELINE_VERSION}]"

echo -e "\n\n########## Get release tags ##########"
if $SKIP_BACK_COMPATIBILITY_CHECKS ; then
    echo "Skipping [SKIP_BACK_COMPATIBILITY_CHECKS=${SKIP_BACK_COMPATIBILITY_CHECKS}]"
elif [[ ! -z "${RELEASE_TAGS}" ]]; then
   echo "Using release list from input parameter:"
   echo "${RELEASE_TAGS}"
else
  echo "Using release list published by last release:"
  echo "---- Raw file contents ----"
  cat "${WORKSPACE}"/.git/tools-releases/fortune-service/ci-releases.properties
  echo "---- Raw file contents (end) ----"
  # File format is [tag=coordinates\n]. Convert to comma-separated list of coordinates.
  separator="" # Blank until first run through loop
  while read line; do
    tag=$(echo ${line} | cut -d "=" -f1)
  	#echo "Adding tag [${tag}]"
	RELEASE_TAGS="${RELEASE_TAGS}${separator}${tag}"
    separator="," # will be populated after first coordinates are set
  done < "${WORKSPACE}"/.git/tools-releases/fortune-service/ci-releases.properties
  echo "Extracted tags:"
  echo "${RELEASE_TAGS}"
fi

echo -e "\n\n########## Test API back compatibility ##########"
if $SKIP_BACK_COMPATIBILITY_CHECKS ; then
    echo "Skipping [SKIP_BACK_COMPATIBILITY_CHECKS=${SKIP_BACK_COMPATIBILITY_CHECKS}]"
elif [[ -z "${RELEASE_TAGS}" ]]; then
    echo "Skipping [RELEASE_TAGS=${RELEASE_TAGS}]"
else
    IFS=","
    releaseTagsArray=($RELEASE_TAGS)
    for ((i=0; i<${#releaseTagsArray[@]}; ++i)); do
        version=${releaseTagsArray[$i]#"prod/${PROJECT_NAME}/"}
        echo -e "\n\n##### Testing with API client from version [${version}]\n\n\n";
        executeApiCompatibilityCheck "${version}"
    done
    unset IFS
fi

echo -e "\n\n########## Run database schema back compatibility tests ##########"
if $SKIP_BACK_COMPATIBILITY_CHECKS ; then
    echo "Skipping [SKIP_BACK_COMPATIBILITY_CHECKS=${SKIP_BACK_COMPATIBILITY_CHECKS}]"
elif [[ -z "${RELEASE_TAGS}" ]]; then
    echo "Skipping [RELEASE_TAGS=${RELEASE_TAGS}]"
else
    # Copy current db/migrations scripts
    # default flyway.locations=filesystem:src/main/resources/db/migration
    # instead, will use flyway.locations=filesystem:.git/db-${current_git_commit}/db/migration
    mkdir -p .git/db-${GIT_COMMIT}
    cp -r src/main/resources/db/migration .git/db-${GIT_COMMIT}/migration
    #BUILD_OPTIONS="-Dspring.flyway.locations=filesystem:.git/db-${GIT_COMMIT}/migration ${BUILD_OPTIONS}"

    # Loop through previous release and check each one against the current db schema
    IFS=","
    releaseTagsArray=($RELEASE_TAGS)
    for ((i=0; i<${#releaseTagsArray[@]}; ++i)); do
        tag="${releaseTagsArray[$i]}"
        "${GIT_BIN}" checkout ${tag}
        # version=${releaseTagsArray[$i]#"prod/${PROJECT_NAME}/"}
        echo -e "\n\n##### Testing [${tag}] against current DB schema [git_commit=${GIT_COMMIT}]\n\n\n";
        rm -r src/main/resources/db/migration
        mkdir -p src/main/resources/db
        cp -r .git/db-${GIT_COMMIT}/migration src/main/resources/db/migration
        runDefaultTests
    done
    "${GIT_BIN}" reset --hard "${GIT_COMMIT}"
    "${GIT_BIN}" clean -f -d
    unset IFS
fi

echo -e "\n\n########## Build and upload ##########"
"${GIT_BIN}" checkout "${GIT_COMMIT}"
build

echo -e "\n\n########## Publish uploaded files ##########"
api=${REPO_WITH_BINARIES_FOR_UPLOAD/maven/content}
curl -X POST ${api}/${PASSED_PIPELINE_VERSION}/publish

echo -e "\n\n########## Build info summary (to archive) ##########"
echo "source=${GIT_URL}" > ci-build.properties
echo "project_name=${PROJECT_NAME}" >> ci-build.properties
echo "commit_id=${GIT_COMMIT}" >> ci-build.properties
echo "build_version=${PASSED_PIPELINE_VERSION}" >> ci-build.properties
echo "skip_back_compat_checks=${SKIP_BACK_COMPATIBILITY_CHECKS}" >> ci-build.properties
echo "api_back_compat=${RELEASE_TAGS}" >> ci-build.properties
echo "db_back_compat=${RELEASE_TAGS}" >> ci-build.properties

cat ci-build.properties