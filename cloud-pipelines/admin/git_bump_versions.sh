#!/usr/bin/env bash
echo "Bumping commit for fortune-service"
pushd ~/workspace/spinnaker-cloud-pipelines-home/fortune-service
echo " " >> src/test/resources/commit-bumper
git add src/test/resources/commit-bumper
git commit -m "bumping commit id"
git push
popd

echo "Bumping commit for greeting-ui"
pushd ~/workspace/spinnaker-cloud-pipelines-home/greeting-ui
echo " " >> src/test/resources/commit-bumper
git add src/test/resources/commit-bumper
git commit -m "bumping commit id"
git push
popd

