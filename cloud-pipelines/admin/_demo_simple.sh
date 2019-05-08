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
echo "2 - Build fortune-service-build-1         (working baseline)"
echo "3 - Test fortune-service-build-2          (breaking api change)"
echo "4 - Build fortune-service-build-3         (back-compatible api change)"
echo "5 - Test fortune-service-build-4          (breaking db change)"
echo "6 - Build fortune-service-build-5         (back-compatible db change)"
echo "7 - Build greeting-ui-build-1             (working baseline, test with stub for fortune-service-build-1)"
echo "8 - Build greeting-ui-build-2             (breaking api change, test with stubs for fortune-service-build-1, fortune-service-build-3 and fortune-service-build-5)"
echo "9 - Build greeting-ui-build-3             (back-compatible api change, test with stubs for fortune-service-build-1, fortune-service-build-3 and fortune-service-build-5)"
echo "q - Quit"
read choice

case ${choice} in
    1)  echo -e "\nCleaning temp dir and cloning repos"
        rm -rf "${DEMO_TEMP}"
        mkdir -p "${DEMO_TEMP}"
        cd "${DEMO_TEMP}"

        git clone https://github.com/ciberkleid/fortune-service.git fortune-service-build-1
        cp -r fortune-service-build-1 fortune-service-build-2
        cp -r fortune-service-build-1 fortune-service-build-3
        cp -r fortune-service-build-1 fortune-service-build-4
        cp -r fortune-service-build-1 fortune-service-build-5

        git clone https://github.com/ciberkleid/greeting-ui.git greeting-ui-build-1
        cp -r greeting-ui-build-1 greeting-ui-build-2
        cp -r greeting-ui-build-1 greeting-ui-build-3

        cd fortune-service-build-1
        git checkout ${FORTUNE_SERVICE_1} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-1" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-build-2
        git checkout ${FORTUNE_SERVICE_2} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-2" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-build-3
        git checkout ${FORTUNE_SERVICE_3} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-3" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-build-4
        git checkout ${FORTUNE_SERVICE_4} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-4" -DprocessAllModules --quiet
        cd ..
        cd fortune-service-build-5
        git checkout ${FORTUNE_SERVICE_5} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-5" -DprocessAllModules --quiet
        cd ..

        cd greeting-ui-build-1
        git checkout ${GREETING_UI_1} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-1" -DprocessAllModules --quiet
        cd ..
        cd greeting-ui-build-2
        git checkout ${GREETING_UI_2} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-2" -DprocessAllModules --quiet
        cd ..
        cd greeting-ui-build-3
        git checkout ${GREETING_UI_3} || { echo >&2 "git checkout failed with $?"; return 1; }
        ./mvnw versions:set -DnewVersion="build-3" -DprocessAllModules --quiet
        cd ..
        ;;
    2) echo -e "\nBuilding fortune-service-build-1 (baseline)"
        cd fortune-service-build-1
        echo -e "\nInitial release - no API or DB back compatibility checks needed. Expecting success."
        rm -rf ~/.m2/repository/io/pivotal/fortune-service/fortune-service-build-1
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-build-1"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-build-1
        cd ..
        ;;
    3) echo -e "\nTesting fortune-service-build-2 (breaking api change)"
        cd fortune-service-build-2
        echo -e "\nTest fortune-service-build-2. Expecting success."
        ./mvnw clean test
        echo -e "\nCheck API back compatibility against fortune-service-build-1. Expecting failure due to known back compatibility issues."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-1 -Dcontracts.mode=LOCAL || { echo >&2 "API compatability test failed with $?"; return 0; }
        echo -e "\nFinished testing fortune-service-build-2"
        cd ..
        ;;
    4) echo -e "\nBuilding fortune-service-build-3 (back-compatible api change)"
        cd fortune-service-build-3
        echo -e "\nCheck API back compatibility against fortune-service-build-1. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-1 -Dcontracts.mode=LOCAL
         echo -e "\nBuild fortune-service-build-3. Expecting success."
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-build-3"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-build-3
        cd ..
        ;;
    5) echo -e "\nTesting fortune-service-build-4 (breaking db change)"
        cd fortune-service-build-4
        echo -e "\nTest fortune-service-build-4. Expecting success."
        ./mvnw clean test
        echo -e "\nCheck DB back compatibility against fortune-service-build-3. Expecting failure due to known back compatibility issues."
        cd ../fortune-service-build-3
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-build-4/src/main/resources/db/migration || { echo >&2 "DB compatability test failed with $?"; return 0; }
        cd ..
        echo -e "\nFinished testing fortune-service-build-4"
        cd ..
        ;;
    6) echo -e "\nTesting fortune-service-build-5 (back-compatible api and db changes)"
        cd fortune-service-build-5
        echo -e "\nCheck API back compatibility against fortune-service-build-3. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-3 -Dcontracts.mode=LOCAL
        echo -e "\nCheck API back compatibility against fortune-service-build-1. Expecting success."
        ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-1 -Dcontracts.mode=LOCAL

        echo -e "\nCheck DB back compatibility against fortune-service-build-3. Expecting success."
        cd ../fortune-service-build-3
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-build-5/src/main/resources/db/migration
        cd ..
        echo -e "\nCheck DB back compatibility against fortune-service-build-1. Expecting success."
        cd ../fortune-service-build-1
        ./mvnw clean test -Dspring.flyway.locations=filesystem:../fortune-service-build-5/src/main/resources/db/migration
        cd ..
        echo -e "\nBuild fortune-service-build-5. Expecting success."
        ./mvnw clean install
        echo -e "\nFinished building fortune-service-build-5"
        echo "Generated files in local m2 repo:"
        ls ~/.m2/repository/io/pivotal/fortune-service/fortune-service-build-5
        cd ..
        ;;
    7) echo -e "\Building greeting-ui-build-1"
        cd greeting-ui-build-1
        echo -e "\Building greeting-ui-build-1. Testing against fortune-service-build-1 stub. Expecting success"
        export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        echo -e "\nFinished building greeting-ui-build-1"
        ls ~/.m2/repository/io/pivotal/greeting-ui/greeting-ui-build-1
        cd ..
        ;;
    8) echo -e "\Building greeting-ui-build-2"
        cd greeting-ui-build-2
        echo -e "\Building greeting-ui-build-2. Testing against fortune-service-build-3 stub. Expecting success"
        export STUBS=io.pivotal:fortune-service:build-3; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        #export STUBS=io.pivotal:fortune-service:build-5; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        echo -e "\Building greeting-ui-build-2. Testing against fortune-service-build-1 stub. Expecting failure"
        export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL || { echo >&2 "API compatability test failed with $?"; return 0; }
        echo -e "\nFinished building greeting-ui-build-2"
        ls ~/.m2/repository/io/pivotal/greeting-ui/greeting-ui-build-2
        cd ..
        ;;
    9) echo -e "\Building greeting-ui-build-3"
        cd greeting-ui-build-3
        echo -e "\Building greeting-ui-build-3. Testing against fortune-service-build-1, fortune-service-build-3 and fortune-service-build-5 stubs. Expecting success"
        export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        export STUBS=io.pivotal:fortune-service:build-3; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        export STUBS=io.pivotal:fortune-service:build-5; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
        echo -e "\nFinished building greeting-ui-build-2"
        ls ~/.m2/repository/io/pivotal/greeting-ui/greeting-ui-build-2
        cd ..
        ;;
    *) exit ;;
esac
