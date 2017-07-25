# Get user input:
echo "Enter the Config Server URI [https://github.com/ciberkleid/app-config]: "
read GIT_URI
echo "Enable C2C Networking? [Y]: "
read C2C
echo "Build apps? [N]: "
read BUILD

# Set variables
CF_API=`cf api | head -1 | cut -c 25-${lastIndex}`
GIT_URI=${GIT_URI:-https://github.com/ciberkleid/app-config}
C2C=${C2C:-Y}
BUILD=${BUILD:-N}

# Creat Config Server JSON Config File
echo "{\"git\": {\"uri\": \"${GIT_URI}\"}}" > cloud-config-uri.json

# Create services
cf create-service p-config-server standard config-server -c cloud-config-uri.json
cf create-service p-service-registry standard service-registry
cf create-service p-circuit-breaker-dashboard standard circuit-breaker-dashboard
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
  cf create-service cloudamqp lemur cloud-bus
else
  cf create-service p-rabbitmq standard cloud-bus
fi

# Build apps
if [[ $BUILD == "Y" ]]; then
  cd fortune-service
  mvn clean install
  cd ../greeting-ui
  mvn clean install
  cd ..
fi

# Wait until services are ready
i=`cf services | grep "in progress" | wc -l`
while [ $i -gt 0 ]
  do
    sleep 5
    echo "Waiting for services to initialize..."
    i=`cf services | grep "in progress" | wc -l`
  done

# Push apps
cf push -f manifest.yml --no-start
cf set-env fortune-service TRUST_CERTS $CF_API
cf set-env greeting-ui TRUST_CERTS $CF_API

# Allow access for C2C networking
if [[ $C2C == "Y" ]]; then
  cf allow-access greeting-ui fortune-service --protocol tcp --port 8080
fi

# Start apps
cf start fortune-service
cf start greeting-ui

