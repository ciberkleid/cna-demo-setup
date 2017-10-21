#!/bin/bash

cf api $PWS_API --skip-ssl-validation

app_spec_file=$(ls ./application-spec/ | grep -v generation | grep -v url)
applications=$(jq '.applications[].name' ./application-spec/$app_spec_file  |  tr -d '"')
environment=$(jq '.environment' ./application-spec/$app_spec_file  |  tr -d '"')

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$environment"

echo Executing E2E Integration tests for $environment

cf routes | grep $environment | awk '{if(NR>1)print $2,$3}'

echo Finished E2E Integration tests for $environment