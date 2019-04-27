#!/usr/bin/env bash
echo "Deleting tags for fortune-service"
pushd ~/workspace/spinnaker-cloud-pipelines-home/fortune-service
#Fetch remote tags.
git fetch
#Delete remote tags.
git push origin --delete $(git tag -l)
#Delete local tags.
git tag -d $(git tag -l)
popd

echo "Deleting tags for greeting-ui"
pushd ~/workspace/spinnaker-cloud-pipelines-home/greeting-ui
#Fetch remote tags.
git fetch
#Delete remote tags.
git push origin --delete $(git tag -l)
#Delete local tags.
git tag -d $(git tag -l)
popd

