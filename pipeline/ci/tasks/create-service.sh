#!/bin/bash


echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

cf api $PWS_API --skip-ssl-validation

echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')
environment=$(jq '.environment' ./application-spec/$app_spec_file  |  tr -d '"')


echo -ne '\n' | cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" 
(cf spaces | grep $environment) || cf create-space "$environment"
cf target -s "$environment"

for application in $applications ; do
    gittag=$(jq --arg v "$application" '.applications[] | select (.name | contains ($v)) | .gittag' ./application-spec/$app_spec_file | tr -d '"')
    gsutil cp "gs://${GCP_BUCKET}/artifacts/$application/$gittag/$application-$gittag-services.txt" ./
    
    services=$(cat $application-$gittag-services.txt)

    # Create Config Server JSON Config File
    echo "{\"git\": {\"uri\": \"${GIT_URI}\"}}" > cloud-config-uri.json

    for service in $services; do
        if [ "$service" == "cloud-bus" ]; then
            if [[ $PWS_API == *"api.run.pivotal.io"* ]]; then
                cf create-service cloudamqp lemur $service
            else
                cf create-service p-rabbitmq standard $service
            fi
        elif [ "$service" == "config-server" ]; then
            echo Creating $service .. 
            cf create-service p-$service standard $service -c cloud-config-uri.json 
        elif [ "$service" != "config-server" ]; then
            echo Creating $service ..
            cf create-service p-$service standard $service
        fi
    done

    # wait for services
    for service in $services; do
        # Wait until services are ready
        i=`cf service $service | grep "in progress" | wc -l`
        while [ $i -gt 0 ]
        do
            sleep 5
            echo "Waiting for $service to initialize..."
            i=`cf service $service | grep "in progress" | wc -l`
        done
        echo "$service initilized"
    done

done