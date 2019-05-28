#!/usr/bin/env bash

# Get user input & set variables
echo "Enter the Config Server URI [https://github.com/ciberkleid/app-config]: "
read GIT_URI
echo "Build apps? [N]: "
read BUILD
echo "Enable C2C Networking? [eureka|mesh|NONE]: "
read C2C

CF_API=`cf api | head -1 | cut -c 17-`
GIT_URI=${GIT_URI:-https://github.com/ciberkleid/app-config}
BUILD=${BUILD:-N}
case ${C2C} in
    e|eureka)
        C2C=Y
        EUREKA=Y
        MANIFEST=manifest-c2c-eureka.yml
    ;;
    m|mesh)
        C2C=Y
        EUREKA=N
        MANIFEST=manifest-c2c-mesh.yml
    ;;
    *)  C2C=N
        EUREKA=Y
        MANIFEST=manifest.yml
    ;;
esac

# Create Config Server JSON Config File
echo "{\"git\": {\"uri\": \"${GIT_URI}\"}}" > cloud-config-uri.json

# Create services
SCS_PLAN=standard
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
  SCS_PLAN=trial
  cf create-service cloudamqp lemur cloud-bus
  cf create-service cleardb spark fortune-db
else
  cf create-service p.rabbitmq single-node-3.7 cloud-bus
  cf create-service p.mysql db-small fortune-db
fi
cf create-service p-config-server $SCS_PLAN config-server -c cloud-config-uri.json
cf create-service p.config-server $SCS_PLAN config-server -c cloud-config-uri.json
cf create-service p-circuit-breaker-dashboard $SCS_PLAN circuit-breaker-dashboard
if [[ $EUREKA == "Y" ]]; then
  cf create-service p-service-registry $SCS_PLAN service-registry
fi 

# Build apps
if [[ $BUILD == "Y" ]]; then
  cd ../fortune-service
  ./mvnw clean install -DskipTests
  cd ../greeting-ui
  ./mvnw clean install -DskipTests
  cd ../cna-demo-setup
fi

# Wait until services are ready
while cf services | grep 'create in progress'
do
  sleep 20
  echo "Waiting for services to initialize..."
done

# Check to see if any services failed to create
if cf services | grep 'create failed'; then
  echo "Service initialization - failed. Exiting."
  return 1
fi
echo "Service initialization - successful"

# Push apps
cd ../fortune-service
cf push -f $MANIFEST --no-start
cd ../greeting-ui
cf push -f $MANIFEST --no-start
cd ../cna-demo-setup

cf set-env fortune-service TRUST_CERTS $CF_API
cf set-env fortune-service TRUST_CERTS $CF_API

if [[ $C2C == "Y" ]]; then
  cf add-network-policy greeting-ui --destination-app fortune-service --protocol tcp --port 8080
fi

# Start apps
cf restage fortune-service
cf restage greeting-ui
