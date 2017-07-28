echo "This script will delete the greeting-ui and fortune-service apps."
echo "Delete services too? [Y]: "
read SERVICES
SERVICES=${SERVICES:-Y}

cf delete greeting-ui -f -r
cf delete fortune-service -f -r

if [[ $SERVICES == "Y" ]]; then
  cf delete-service config-server -f
  cf delete-service cloud-bus -f
  cf delete-service service-registry -f
  cf delete-service circuit-breaker-dashboard -f
fi
