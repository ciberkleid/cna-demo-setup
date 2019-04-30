#!/usr/bin/env bash

##### PRE-REQS ####################
# To run this demo, execute the following commands:
#   mkdir cna-demo
#   cd cna-demo
#   git clone https://github.com/ciberkleid/cna-demo-setup.git
#   source cna-demo-setup/cloud-pipelines/admin/_demo_simple.sh
###################################

savedPWD=`pwd`

source cna-demo-setup/cloud-pipelines/admin/_demo_env.sh

DEMO_TEMP="${savedPWD}"/_demo_temp

echo -e "\n########## DEMO CONTROLLER ##########"
echo -e "\nChoose an option? [1-5]: "
echo "1 - Clone repos"
echo "2 - Build fortune-service-1           (working baseline)"
echo "3 - Test fortune-service-2-snapshot   (breaking api change)"
echo "4 - Build fortune-service-2           (back-compatible api change)"
echo "5 - Test fortune-service-3-snapshot   (breaking db change)"
echo "6 - Build fortune-service-3           (back-compatible api and db changes)"
echo "9 - Exit"
read choice

case ${choice} in
    1)  echo -e "\nCleaning temp dir and cloning repos"
        rm -rf "${DEMO_TEMP}"
        mkdir -p "${DEMO_TEMP}"
        cd "${DEMO_TEMP}"

        git clone https://github.com/ciberkleid/fortune-service.git fortune-service-1
        cp -r fortune-service-1 fortune-service-2-snapshot
        cp -r fortune-service-1 fortune-service-2
        cp -r fortune-service-1 fortune-service-3-snapshot
        cp -r fortune-service-1 fortune-service-3

        git clone https://github.com/ciberkleid/greeting-ui.git greeting-ui-1
        #cp -r greeting-ui-blue greeting-ui-2

        cd fortune-service-1
        git checkout ${FORTUNE_SERVICE_1} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="fortune-service-1" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-2-snapshot
        git checkout ${FORTUNE_SERVICE_2_SNAPSHOT} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="fortune-service-2-snapshot" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-2
        git checkout ${FORTUNE_SERVICE_2} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="fortune-service-2" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-3-snapshot
        git checkout ${FORTUNE_SERVICE_3_SNAPSHOT} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="fortune-service3-snapshot" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-3
        git checkout ${FORTUNE_SERVICE_3} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="fortune-service-3" -DprocessAllModules --quiet
        cd ..

        cd greeting-ui-1
        git checkout ${GREETING_UI_1} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="greeting-ui-1" -DprocessAllModules --quiet
        cd ..
        #cd greeting-ui-2
        #git checkout ${GREETING_UI_2} || { echo >&2 "git checkout failed with $?"; return 1; }
        #./mvnw versions:set -DnewVersion="greeting-ui-2" -DprocessAllModules --quiet
        #cd ..
        ;;
    2) echo -e "\nBuilding fortune-service-1 (baseline))"
        cd fortune-service-1
        echo -e "\nInitial release - no API or DB back compatibility checks needed. Expecting success."
        rm -rf ~/.m2/repository/io/pivotal/fortune-service/fortune-service-1
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-1"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-1
        cd ..
        ;;
    3) echo -e "\nTesting fortune-service-2-snapshot (breaking api change)"
        cd fortune-service-2-snapshot
        echo -e "\nTest fortune-service-2-snapshot. Expecting success."
        ./mvnw clean test
        echo -e "\nCheck API back compatibility against fortune-service-1. Expecting failure due to known back compatibility issues."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=1 -Dcontracts.mode=LOCAL
        echo -e "\nFinished testing fortune-service-2-snapshot"
        cd ..
        ;;
    4) echo -e "\nBuilding fortune-service-2 (back-compatible api change)"
        cd fortune-service-2
        echo -e "\nCheck API back compatibility against fortune-service-1. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=1 -Dcontracts.mode=LOCAL
         echo -e "\nBuild fortune-service-2. Expecting success."
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-2"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-2
        cd ..
        ;;
    5) echo -e "\nTesting fortune-service-3-snapshot (breaking db change)"
        cd fortune-service-3-snapshot
        echo -e "\nTest fortune-service-3-snapshot. Expecting success."
        ./mvnw clean test
        echo -e "\nCheck DB back compatibility against fortune-service-2. Expecting failure due to known back compatibility issues."
        cd ../fortune-service-2
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-3-snapshot/src/main/resources/db/migration
        cd ..
        echo -e "\nFinished testing fortune-service-3-snapshot"
        cd ..
        ;;
    6) echo -e "\nTesting fortune-service-3 (back-compatible api and db changes)"
        cd fortune-service-3
        echo -e "\nCheck API back compatibility against fortune-service-2. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=2 -Dcontracts.mode=LOCAL
        echo -e "\nCheck API back compatibility against fortune-service-1. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=1 -Dcontracts.mode=LOCAL

        echo -e "\nCheck DB back compatibility against fortune-service-2. Expecting success."
        cd ../fortune-service-2
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-3-snapshot/src/main/resources/db/migration
        cd ..
        echo -e "\nCheck DB back compatibility against fortune-service-1. Expecting success."
        cd ../fortune-service-1
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-3-snapshot/src/main/resources/db/migration
        cd ..
        echo -e "\nBuild fortune-service-3. Expecting success."
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-3"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-3
        cd ..
        ;;
    *) exit ;;
esac





