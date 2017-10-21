#!/bin/bash

# Functions
function git_fetch {
    echo Fetching $1 with tag $3 from $2
    mkdir -p ./tmp
    pushd ./tmp
    git clone -b $3 --single-branch $2 $1
    popd
}

function maven_build {
    echo Starting to build $1

    pushd ./tmp
    cd $1
    mvn clean install
    mkdir -p ../../application-artifacts/$1
    mv target/$1-0.0.1-SNAPSHOT.jar ../../application-artifacts/$1/$1-$2.jar
    mv manifest.yml ../../application-artifacts/$1/$1-$2-manifest.yml
    popd
}

# Main
echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')

for application in $applications ; do 
    #git_fetch
    gitrepo=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gitrepo' ./application-spec/$app_spec_file | tr -d '"')
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')
    git_fetch $application $gitrepo $gittag
    
    # build and move artifacts
    maven_build $application $gittag   
done