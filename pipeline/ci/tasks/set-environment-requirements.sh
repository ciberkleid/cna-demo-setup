#!/bin/bash
# Main
echo Detecting Apps required
app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')
environment=$(jq '.environment' ./application-spec/$app_spec_file  |  tr -d '"')

cf api $PWS_API --skip-ssl-validation
cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$environment"

if [[ $C2C == "Y" ]]; then

  
  cf install-plugin network-policy -f 

  for application in $applications ; do 
       cf set-env $application SPRING_PROFILES_ACTIVE c2c 
  done

   cf allow-access "$applications" --protocol tcp --port 8080

fi

for application in $applications ; do 
    cf restage $application
done