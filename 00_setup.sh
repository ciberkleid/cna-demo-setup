# Get user input:
echo "Enter the Config Server URI [https://github.com/ciberkleid/app-config]: "
read GIT_URI
echo "Enable C2C Networking? [N]: "
read C2C
echo "Build apps? [N]: "
read BUILD

# Set variables
CF_API=`cf api | head -1 | cut -c 25-`
GIT_URI=${GIT_URI:-https://github.com/ciberkleid/app-config}
C2C=${C2C:-N}
BUILD=${BUILD:-N}
MANIFEST=manifest.yml

# Create Config Server JSON Config File
echo "{\"git\": {\"uri\": \"${GIT_URI}\"}}" > cloud-config-uri.json

# Create services
cf create-service p-config-server standard config-server -c cloud-config-uri.json
cf create-service p-service-registry standard service-registry
cf create-service p-circuit-breaker-dashboard standard circuit-breaker-dashboard
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
  cf create-service cloudamqp lemur cloud-bus
  cf create-service cleardb spark fortune-db
else
  cf create-service p-rabbitmq standard cloud-bus
  cf create-service p-mysql 100mb fortune-db
fi

# Build apps
if [[ $BUILD == "Y" ]]; then
  cd ../fortune-service
  mvn clean install
  cd ../greeting-ui
  mvn clean install
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
cf push -f $MANIFEST --no-start

# Set env variables and optionally enable c2c access
cf set-env fortune-service TRUST_CERTS $CF_API
cf set-env greeting-ui TRUST_CERTS $CF_API
if [[ $C2C == "Y" ]]; then
  cf set-env fortune-service SPRING_PROFILES_ACTIVE c2c,ddlupdate
  cf set-env greeting-ui SPRING_PROFILES_ACTIVE c2c
  cf allow-access greeting-ui fortune-service --protocol tcp --port 8080
else
  cf set-env fortune-service SPRING_PROFILES_ACTIVE ddlupdate
fi

# Start apps
cf start fortune-service
cf start greeting-ui

