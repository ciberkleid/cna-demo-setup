# Get user input:
echo "Delete apps? [Y]: "
read APPS
APPS=${APPS:-Y}

echo "Delete services? [Y]: "
read SERVICES
SERVICES=${SERVICES:-Y}

#currentSpace=`cf target | grep "space:" | cut -c 17-${lastIndex}`
#echo "Delete current space '$currentSpace'? [N]: "
#read SPACE
#SPACE=${SPACE:-N}

if [[ $APPS == "Y" ]]; then
  cf delete greeting-ui -f -r
  cf delete fortune-service -f -r
fi

if [[ $SERVICES == "Y" ]]; then
  cf delete-service config-server -f
  cf delete-service cloud-bus -f
  cf delete-service service-registry -f
  cf delete-service circuit-breaker-dashboard -f
fi

#echo "Continuing will delete EVERYTHING in this space. Continue? [Y]: "
#read DELETE
#DELETE=${DELETE:-Y}

#if [[ $DELETE == "Y" ]]; then
#  cf delete-space -f $SPACE
#  cf create-space $SPACE
#  cf target -s $SPACE
#else 
#  echo "Space cleanup aborted"
#fi
