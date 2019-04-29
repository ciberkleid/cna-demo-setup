#!/usr/bin/env bash
pushd ~/workspace/spinnaker-cloud-pipelines-home/cna-demo-setup

echo "Deleting archive from local and remote"
rm cloud-pipelines/dist/cloud-pipelines-ext.tar.gz
git rm cloud-pipelines/dist/cloud-pipelines-ext.tar.gz
git commit -m "deleting archive"
git push

echo "Recreating and pushing archive in local and remote"
mkdir -p cloud-pipelines/dist
git archive -o cloud-pipelines/dist/cloud-pipelines-ext.tar.gz HEAD:cloud-pipelines/ext
git add cloud-pipelines/dist/cloud-pipelines-ext.tar.gz
git commit -m "pushing distro"
git push

popd
