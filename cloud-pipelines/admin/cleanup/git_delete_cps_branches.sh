#!/usr/bin/env bash

echo "Deleting tags for fortune-service"
pushd ~/workspace/spinnaker-cloud-pipelines-home/fortune-service
git branch -D cloud-pipelines-spinnaker
git push origin --delete cloud-pipelines-spinnaker
popd

echo "Deleting tags for greeting-ui"
pushd ~/workspace/spinnaker-cloud-pipelines-home/greeting-ui
git branch -D cloud-pipelines-spinnaker
git push origin --delete cloud-pipelines-spinnaker
popd
