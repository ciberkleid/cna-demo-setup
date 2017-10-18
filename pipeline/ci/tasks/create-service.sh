#!/bin/bash


echo $GCP_SERVICE_ACCOUNT_KEY > gcloud.key
gcloud auth activate-service-account --key-file=gcloud.key

# Get commit SHA of the application
app_version=$(cat $APP_NAME-src/.git/ref)

gsutil cp "gs://${GCP_BUCKET}/$APP_NAME/$app_version/services.txt" ./

cf api $PWS_API --skip-ssl-validation

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$PWS_SPACE"

GIT_URI=${GIT_URI:-https://github.com/ciberkleid/app-config}
services=$(cat services.txt)

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

