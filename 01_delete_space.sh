# Get user input:
currentSpace=`cf target | grep "space:" | cut -c 17-${lastIndex}`
echo "Enter cf space name [$currentSpace]: "
read SPACE
SPACE=${SPACE:-$currentSpace}

echo "Continuing will delete EVERYTHING in this space. Continue? [Y]: "
read DELETE
DELETE=${DELETE:-Y}

if [[ $DELETE == "Y" ]]; then
  cf delete-space -f $SPACE
  cf create-space $SPACE
  cf target -s $SPACE
else 
  echo "Space cleanup aborted"
fi
