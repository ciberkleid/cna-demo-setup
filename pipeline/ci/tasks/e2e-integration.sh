#!/bin/bash

cf api $PWS_API --skip-ssl-validation

cf login -u $PWS_USER -p $PWS_PWD -o "$PWS_ORG" -s "$PWS_SPACE"

echo Executing E2E Integration tests for $PWS_SPACE

cf routes | grep $PWS_SPACE | awk '{if(NR>1)print $2,$3}'

echo Finished E2E Integration tests for $PWS_SPACE