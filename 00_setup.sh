# Get user input:
echo "Enter the Config Server URI [https://github.com/ciberkleid/app-config]: "
read GIT_URI
echo "Enable C2C Networking? [N]: "
read C2C
echo "Build apps? [N]: "
read BUILD
echo "Use random routes? [Y]: "
read RAND_ROUTES

# Set variables
CF_API=`cf api | head -1 | cut -c 25-`
GIT_URI=${GIT_URI:-https://github.com/ciberkleid/app-config}
C2C=${C2C:-N}
BUILD=${BUILD:-N}
RAND_ROUTES=${RAND_ROUTES:-Y}

# Create Config Server JSON Config File
echo "{\"git\": {\"uri\": \"${GIT_URI}\"}}" > cloud-config-uri.json

# Create services
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
  cf create-service p-config-server trial config-server -c cloud-config-uri.json
  cf create-service p-service-registry trial service-registry
  cf create-service p-circuit-breaker-dashboard trial circuit-breaker-dashboard
  cf create-service cloudamqp lemur cloud-bus
  cf create-service cleardb spark fortune-db
else
  cf create-service p-config-server standard config-server -c cloud-config-uri.json
  cf create-service p-service-registry standard service-registry
  cf create-service p-circuit-breaker-dashboard standard circuit-breaker-dashboard
  cf create-service p.rabbitmq single-node-3.7 cloud-bus
  cf create-service p.mysql db-small fortune-db
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
if [[ $RAND_ROUTES == "Y" ]]; then
  cd ../fortune-service
  cf push --no-start --random-route
  cd ../greeting-ui
  cf push --no-start --random-route
  cd ../cna-demo-setup
else
  cd ../fortune-service
  cf push --no-start
  cd ../greeting-ui
  cf push --no-start
  cd ../cna-demo-setup
fi

# Set env variables and optionally enable c2c access
if [[ $C2C == "Y" ]]; then
  cf set-env fortune-service SPRING_PROFILES_ACTIVE c2c
  cf set-env greeting-ui SPRING_PROFILES_ACTIVE c2c
  cf add-network-policy greeting-ui --destination-app fortune-service --protocol tcp --port 8080
fi

# Start apps
cf start fortune-service
cf start greeting-ui

