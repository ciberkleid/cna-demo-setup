#!/bin/bash

if [[ $C2C == "Y" ]]; then
  echo C2C workflow requested
  cf set-env fortune-service SPRING_PROFILES_ACTIVE c2c
  cf set-env greeting-ui SPRING_PROFILES_ACTIVE c2c
  cf install-plugin network-policy -f 
  cf allow-access greeting-ui fortune-service --protocol tcp --port 8080
  cf restage fortune-service
  cf restage greeting-ui
  cf api $PWS_API --skip-ssl-validation
  cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$PWS_SPACE"
fi