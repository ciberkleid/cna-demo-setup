#!/bin/bash

set -o errexit

export TAG_PREFIX="prod/${PROJECT_NAME}/"

echo -e "\n\n########## Get recent release tags ##########"
echo "Max prior tags to retrieve: [${BACK_COMPATIBILITY_DEPTH}]"
groupId="$(extractMavenProperty "project.groupId")"
currentTag="${TAG_PREFIX}${TRIGGER_BUILD_VERSION}"
currentCoordinates="${groupId}:${PROJECT_NAME}:${TRIGGER_BUILD_VERSION}"
echo "${currentTag}=${currentCoordinates}" > ci-releases.properties

latestProdTags=$(findLatestProdTags)

i=0
for tag in ${latestProdTags[@]}
do
    version=$(echo ${tag} | sed -e "s|${TAG_PREFIX}||") # use | for sed to avoid conflicts with / in values
    echo "${tag}=${groupId}:${PROJECT_NAME}:${version}" >> ci-releases.properties
	i=$((i + 1))
done

echo -e "\n\n########## Release history summary (to archive) ##########"
cat ci-releases.properties

echo -e "\n\n########## Build info summary (to archive) ##########"
echo "source=${GIT_URL}" > ci-build.properties
echo "project_name=${PROJECT_NAME}" >> ci-build.properties
echo "commit_id=${TRIGGER_COMMIT_ID}" >> ci-build.properties
echo "build_version=${TRIGGER_BUILD_VERSION}" >> ci-build.properties
echo "tag_name=${TAG_PREFIX}${TRIGGER_BUILD_VERSION}" >> ci-build.properties

cat ci-build.properties

echo -e "\n\n########## Tag Release ##########"
echo "Applying tag [${TAG_PREFIX}${TRIGGER_BUILD_VERSION}] to commit [${TRIGGER_COMMIT_ID}]"
"${GIT_BIN}" checkout ${TRIGGER_COMMIT_ID}
# Tagging will happen through post-build action

# Jenkins hack:
# TAG_PREFIX is hard-coded in post build-step
# Alternative: use a plug-in to inject it as an env variable that
# will be available in the post-build step environment