pushd ~/workspace/spinnaker-cloud-pipelines-home/cna-demo-setup
mkdir -p cloud-pipelines/dist
git archive -o cloud-pipelines/dist/cloud-pipelines-ext.tar.gz HEAD:cloud-pipelines/ext
git add cloud-pipelines/dist/cloud-pipelines-ext.tar.gz
git commit -m "pushing distro"
git push
popd
