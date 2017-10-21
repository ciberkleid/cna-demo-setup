#!/bin/sh

echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')

function parse_manifest {
    echo Parsing Manifest for $1
    ls ./application-artifacts/*
    mkdir -p application-bundle/$1/$2
    cp -r application-artifacts/$1/* application-bundle/$1/$2/ 
    services=$(yaml2json < application-bundle/$1/$2/$1-$2-manifest.yml | jq '.applications[].services[]' |  tr -d '"')
    echo $services > application-bundle/$1/$2/$1-$2-services.txt
}

for application in $applications ; do 
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')
    parse_manifest $application $gittag
done