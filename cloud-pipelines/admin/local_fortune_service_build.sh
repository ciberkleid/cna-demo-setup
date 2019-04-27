RELEASE_TAGS="${1}"
PROJECT_NAME="fortune-service"
M2_SETTINGS_REPO_USERNAME="ciberkleid"
#M2_SETTINGS_REPO_PASSWORD=""
M2_SETTINGS_REPO_ROOT="maven-repo"
REPO_WITH_BINARIES=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@dl.bintray.com/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}
BUILD_OPTIONS=

pushd ~/workspace/spinnaker-cloud-pipelines-home/${PROJECT_NAME}

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
    git checkout ${tag}
    echo -e "\n\n##### Testing [${tag}] against current DB schema\n\n\n";
    rm -r src/main/resources/db/migration
    mkdir -p src/main/resources/db
    cp -r ${CURRENT_ROOT}/src/main/resources/db/migration src/main/resources/db/migration
    #runDefaultTests
    ./mvnw clean test -Pdefault ${BUILD_OPTIONS}
done
rm -rf ../${PROJECT_NAME}-temp
unset IFS

cd ${CURRENT_ROOT}
./mvnw clean install ${BUILD_OPTIONS}

popd
